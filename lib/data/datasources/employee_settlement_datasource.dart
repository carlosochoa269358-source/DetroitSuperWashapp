import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/employee_pending_summary_entity.dart';
import '../../domain/entities/pending_commission_entity.dart';

class EmployeeSettlementDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  /// Filas de service_order_workers sin liquidar cuya orden ya está 'paid'
  /// (plata que ya entró a caja). [employeeId] opcional para un solo trabajador.
  Future<List<Map<String, dynamic>>> _unsettledPaidRows({String? employeeId}) async {
    var query = _client.from('service_order_workers').select('''
          id, employee_id, commission_amount,
          employees(full_name, commission_pct, is_active),
          service_orders(id, order_number, status, created_at, final_price, vehicles(plate))
        ''').eq('is_settled', false);
    if (employeeId != null) {
      query = query.eq('employee_id', employeeId);
    }
    final data = await query;
    final rows = (data as List).cast<Map<String, dynamic>>();
    return rows.where((row) {
      final order = row['service_orders'] as Map<String, dynamic>?;
      final employee = row['employees'] as Map<String, dynamic>?;
      return order != null && order['status'] == 'paid' && employee != null && employee['is_active'] == true;
    }).toList();
  }

  List<PendingCommissionEntity> _toPendingCommissions(List<Map<String, dynamic>> rows) {
    return rows.map((row) {
      final order = row['service_orders'] as Map<String, dynamic>;
      final vehicle = order['vehicles'] as Map<String, dynamic>?;
      return PendingCommissionEntity(
        serviceOrderWorkerId: row['id'] as String,
        serviceOrderId: order['id'] as String,
        orderNumber: order['order_number'] as String?,
        vehiclePlate: vehicle?['plate'] as String?,
        serviceDate: DateTime.parse(order['created_at'] as String),
        orderFinalPrice: (order['final_price'] as num).toDouble(),
        commissionAmount: (row['commission_amount'] as num).toDouble(),
      );
    }).toList();
  }

  /// Cuánto se le debe a cada trabajador activo (comisión de órdenes ya
  /// pagadas, sin liquidar todavía), para la tarjeta de Liquidación en Caja.
  Future<List<EmployeePendingSummaryEntity>> getPendingSummary() async {
    final rows = await _unsettledPaidRows();
    final totals = <String, double>{};
    final counts = <String, int>{};
    final names = <String, String>{};
    final pcts = <String, double>{};

    for (final row in rows) {
      final employeeId = row['employee_id'] as String;
      final employee = row['employees'] as Map<String, dynamic>;
      totals[employeeId] = (totals[employeeId] ?? 0) + (row['commission_amount'] as num).toDouble();
      counts[employeeId] = (counts[employeeId] ?? 0) + 1;
      names[employeeId] = employee['full_name'] as String;
      pcts[employeeId] = (employee['commission_pct'] as num).toDouble();
    }

    final summaries = totals.entries
        .map((e) => EmployeePendingSummaryEntity(
              employeeId: e.key,
              employeeName: names[e.key]!,
              commissionPct: pcts[e.key]!,
              pendingCount: counts[e.key]!,
              pendingTotal: e.value,
            ))
        .toList();
    summaries.sort((a, b) => b.pendingTotal.compareTo(a.pendingTotal));
    return summaries;
  }

  /// Liquida TODO lo pendiente de un trabajador de una sola vez (no permite
  /// pagos parciales por ahora) y lo descuenta del método de pago elegido en
  /// el turno actual.
  Future<void> liquidateAllPending({
    required String companyId,
    required String employeeId,
    required String cashRegisterId,
    required String settledBy,
    required double commissionPct,
    required String paymentMethod,
    String? notes,
  }) async {
    final rows = await _unsettledPaidRows(employeeId: employeeId);
    final items = _toPendingCommissions(rows);
    if (items.isEmpty) {
      throw Exception('Este trabajador no tiene comisión pendiente por liquidar.');
    }

    final dates = items.map((i) => i.serviceDate).toList()..sort();
    final periodFrom = dates.first;
    final periodTo = dates.last;
    final totalSales = items.fold<double>(0, (sum, i) => sum + i.orderFinalPrice);
    final totalCommission = items.fold<double>(0, (sum, i) => sum + i.commissionAmount);
    final dateFormat = DateFormat('yyyy-MM-dd');

    final settlement = await _client
        .from('employee_settlements')
        .insert({
          'company_id': companyId,
          'employee_id': employeeId,
          'cash_register_id': cashRegisterId,
          'settled_by': settledBy,
          'period_from': dateFormat.format(periodFrom),
          'period_to': dateFormat.format(periodTo),
          'total_sales': totalSales,
          'commission_pct': commissionPct,
          'commission_earned': totalCommission,
          'commission_paid': totalCommission,
          'payment_method': paymentMethod,
          'notes': notes,
          'status': 'closed',
        })
        .select()
        .single();

    final settlementId = settlement['id'] as String;

    await _client.from('employee_settlement_items').insert([
      for (final item in items)
        {
          'settlement_id': settlementId,
          'service_order_id': item.serviceOrderId,
          'service_order_worker_id': item.serviceOrderWorkerId,
          'service_date': dateFormat.format(item.serviceDate),
          'commission_amount': item.commissionAmount,
        },
    ]);

    await _client
        .from('service_order_workers')
        .update({'is_settled': true, 'settlement_id': settlementId})
        .inFilter('id', items.map((i) => i.serviceOrderWorkerId).toList());
  }
}
