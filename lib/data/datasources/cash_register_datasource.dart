import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/payment_method_total_entity.dart';
import '../../domain/entities/services_summary_entity.dart';
import '../models/cash_register_model.dart';

class CashRegisterDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  /// El turno abierto más antiguo (si hay varios sin cerrar, se cierra primero el más viejo).
  Future<CashRegisterModel?> getAnyOpen(String companyId) async {
    final data = await _client
        .from('cash_registers')
        .select()
        .eq('company_id', companyId)
        .eq('status', 'open')
        .order('opening_date')
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return CashRegisterModel.fromJson(data);
  }

  /// Efectivo esperado en caja: pagos directos en efectivo + abonos de
  /// fiados en efectivo registrados durante el turno.
  Future<double> cashPaymentsTotal(String cashRegisterId) async {
    final payments = await _client
        .from('payments')
        .select('amount')
        .eq('cash_register_id', cashRegisterId)
        .eq('payment_method', 'efectivo')
        .eq('is_reversed', false);
    final abonos = await _client
        .from('accounts_receivable_payments')
        .select('amount')
        .eq('cash_register_id', cashRegisterId)
        .eq('payment_method', 'efectivo');
    double total = 0;
    for (final row in [...(payments as List), ...(abonos as List)]) {
      total += (row['amount'] as num).toDouble();
    }
    return total;
  }

  /// Desglose de dinero recibido en el turno por método de pago (pagos
  /// directos + abonos de fiados), para la pestaña Caja.
  Future<List<PaymentMethodTotal>> paymentMethodTotals(String cashRegisterId) async {
    final direct = await _client
        .from('payments')
        .select('payment_method, amount')
        .eq('cash_register_id', cashRegisterId)
        .eq('is_reversed', false);
    final abonos = await _client
        .from('accounts_receivable_payments')
        .select('payment_method, amount')
        .eq('cash_register_id', cashRegisterId);

    final totals = <String, double>{};
    final counts = <String, int>{};
    for (final row in [...(direct as List), ...(abonos as List)]) {
      final method = row['payment_method'] as String;
      final amount = (row['amount'] as num).toDouble();
      totals[method] = (totals[method] ?? 0) + amount;
      counts[method] = (counts[method] ?? 0) + 1;
    }
    return totals.entries
        .map((e) => PaymentMethodTotal(method: e.key, count: counts[e.key]!, total: e.value))
        .toList();
  }

  /// Cuántos servicios (líneas, no órdenes) se hicieron durante el turno y
  /// su valor sumado. Excluye órdenes anuladas.
  Future<ServicesSummaryEntity> servicesSummary(String cashRegisterId) async {
    final orderRows = await _client
        .from('service_orders')
        .select('id')
        .eq('cash_register_id', cashRegisterId)
        .neq('status', 'cancelled');
    final orderIds = (orderRows as List).map((r) => r['id'] as String).toList();
    if (orderIds.isEmpty) return const ServicesSummaryEntity(count: 0, total: 0);

    final items = await _client
        .from('service_order_items')
        .select('final_price')
        .inFilter('service_order_id', orderIds);
    final rows = items as List;
    double total = 0;
    for (final row in rows) {
      total += (row['final_price'] as num).toDouble();
    }
    return ServicesSummaryEntity(count: rows.length, total: total);
  }

  Future<CashRegisterModel> open({
    required String companyId,
    required String userId,
    required double openingAmount,
    Map<String, dynamic>? denominations,
  }) async {
    final today = DateFormat('yyyy-MM-dd').format(DateFormatter.todayBogota());
    final data = await _client
        .from('cash_registers')
        .insert({
          'company_id': companyId,
          'opened_by': userId,
          'opening_date': today,
          'opening_amount': openingAmount,
          'opening_denominations': denominations,
          'status': 'open',
        })
        .select()
        .single();
    return CashRegisterModel.fromJson(data);
  }

  /// Cuenta las órdenes del turno que todavía no se resolvieron (ni pagadas,
  /// ni fiadas, ni anuladas). Se usa para dar un mensaje claro antes de
  /// intentar cerrar — la base de datos también lo bloquea como respaldo.
  Future<int> countUnresolvedOrders(String cashRegisterId) async {
    final data = await _client
        .from('service_orders')
        .select('id')
        .eq('cash_register_id', cashRegisterId)
        .inFilter('status', ['new', 'finished']);
    return (data as List).length;
  }

  Future<void> close({
    required String id,
    required String closedBy,
    required double expectedAmount,
    required double countedAmount,
    String? differenceReason,
  }) async {
    final pending = await countUnresolvedOrders(id);
    if (pending > 0) {
      throw Exception(
        'No se puede cerrar el turno: hay $pending orden(es) sin terminar o sin cobrar todavía.',
      );
    }

    await _client
        .from('cash_registers')
        .update({
          'closed_by': closedBy,
          'closing_amount_expected': expectedAmount,
          'closing_amount_counted': countedAmount,
          'closing_difference': countedAmount - expectedAmount,
          'difference_reason': differenceReason,
          'status': 'closed',
          'closed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Turnos cerrados de la empresa, con quién los abrió/cerró, para el historial.
  Future<List<CashRegisterModel>> getClosedHistory(String companyId) async {
    final data = await _client
        .from('cash_registers')
        .select('''
          *,
          opened_by_user:users!cash_registers_opened_by_fkey(full_name),
          closed_by_user:users!cash_registers_closed_by_fkey(full_name)
        ''')
        .eq('company_id', companyId)
        .eq('status', 'closed')
        .order('closed_at', ascending: false);
    return (data as List).map((e) => CashRegisterModel.fromJson(e)).toList();
  }
}
