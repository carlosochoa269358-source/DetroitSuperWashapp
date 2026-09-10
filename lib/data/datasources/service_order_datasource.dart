import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_order_model.dart';

class ServiceOrderDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  static const _selectWithJoins = '''
    *,
    customers(full_name, phone),
    vehicles(plate),
    services(name),
    service_order_workers(employees(full_name))
  ''';

  Future<List<ServiceOrderModel>> getByStatus({
    required String companyId,
    required String status,
  }) async {
    final data = await _client
        .from('service_orders')
        .select(_selectWithJoins)
        .eq('company_id', companyId)
        .eq('status', status)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ServiceOrderModel.fromJson(e)).toList();
  }

  Future<ServiceOrderModel> create({
    required String companyId,
    required String cashRegisterId,
    required String customerId,
    required String vehicleId,
    required String serviceId,
    required String createdBy,
    required double basePrice,
    required double discountAmount,
    required double commissionPct,
    required String employeeId,
  }) async {
    final finalPrice = basePrice - discountAmount;
    final commissionAmount = finalPrice * commissionPct / 100;
    final detroitAmount = finalPrice - commissionAmount;

    final order = await _client
        .from('service_orders')
        .insert({
          'company_id': companyId,
          'cash_register_id': cashRegisterId,
          'customer_id': customerId,
          'vehicle_id': vehicleId,
          'service_id': serviceId,
          'created_by': createdBy,
          'base_price': basePrice,
          'discount_amount': discountAmount,
          'final_price': finalPrice,
          'commission_pct': commissionPct,
          'commission_amount': commissionAmount,
          'detroit_amount': detroitAmount,
        })
        .select()
        .single();

    final orderId = order['id'] as String;
    await _client.from('service_order_workers').insert({
      'service_order_id': orderId,
      'employee_id': employeeId,
      'commission_pct': commissionPct,
      'commission_amount': commissionAmount,
    });

    final data = await _client.from('service_orders').select(_selectWithJoins).eq('id', orderId).single();
    return ServiceOrderModel.fromJson(data);
  }

  Future<void> finalize(String orderId) async {
    await _client
        .from('service_orders')
        .update({'status': 'finished', 'finished_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', orderId);
  }

  /// Registra el pago (total o parcial) de una orden finalizada. Si queda un saldo
  /// pendiente (incluido el caso "Fiar" con abono = 0), crea la cuenta por cobrar
  /// y mueve la orden a 'receivable'. El trigger de la base de datos ya se encarga
  /// de marcarla 'paid' cuando el pago cubre el total.
  Future<void> settlePayment({
    required String orderId,
    required String companyId,
    required String customerId,
    required String cashRegisterId,
    required String registeredBy,
    required double finalPrice,
    required double amountPaid,
    String? paymentMethod,
  }) async {
    if (amountPaid > 0) {
      await _client.from('payments').insert({
        'service_order_id': orderId,
        'cash_register_id': cashRegisterId,
        'registered_by': registeredBy,
        'amount': amountPaid,
        'payment_method': paymentMethod,
      });
    }

    final remaining = finalPrice - amountPaid;
    if (remaining > 0.01) {
      await _client.from('accounts_receivable').insert({
        'company_id': companyId,
        'service_order_id': orderId,
        'customer_id': customerId,
        'original_amount': remaining,
        'pending_amount': remaining,
      });
      await _client.from('service_orders').update({'status': 'receivable'}).eq('id', orderId);
    }
  }
}
