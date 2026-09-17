import '../../domain/entities/service_order_entity.dart';

class ServiceOrderModel extends ServiceOrderEntity {
  ServiceOrderModel({
    required super.id,
    required super.companyId,
    required super.orderNumber,
    required super.cashRegisterId,
    super.paidCashRegisterId,
    required super.customerId,
    required super.vehicleId,
    required super.createdBy,
    required super.status,
    required super.discountAmount,
    required super.finalPrice,
    required super.commissionAmount,
    required super.paidAmount,
    required super.pendingAmount,
    required super.createdAt,
    super.finishedAt,
    super.paidAt,
    super.customerName,
    super.customerPhone,
    super.vehiclePlate,
    super.vehicleTypeId,
    super.workerName,
    super.serviceNames,
    super.paymentMethods,
  });

  /// Soporta filas con los recursos embebidos customers/vehicles/
  /// service_order_workers(employees)/service_order_items(services).
  factory ServiceOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customers'] as Map<String, dynamic>?;
    final vehicle = json['vehicles'] as Map<String, dynamic>?;
    final workers = json['service_order_workers'] as List<dynamic>?;
    String? workerName;
    if (workers != null && workers.isNotEmpty) {
      final employee = (workers.first as Map<String, dynamic>)['employees'] as Map<String, dynamic>?;
      workerName = employee?['full_name'] as String?;
    }

    final items = json['service_order_items'] as List<dynamic>?;
    final serviceNames = <String>[
      if (items != null)
        for (final item in items)
          if ((item as Map<String, dynamic>)['services'] != null)
            (item['services'] as Map<String, dynamic>)['name'] as String,
    ];

    // Métodos de pago: los directos (tabla payments, sin reversar) más los
    // abonos de fiado que terminaron de saldar la orden (accounts_receivable
    // -> accounts_receivable_payments) — puede haber de los dos si se pagó
    // parte de contado y el resto después.
    final paymentsJson = json['payments'] as List<dynamic>?;
    final receivablesJson = json['accounts_receivable'] as List<dynamic>?;
    final paymentMethods = <String>{
      if (paymentsJson != null)
        for (final p in paymentsJson)
          if ((p as Map<String, dynamic>)['is_reversed'] != true && p['payment_method'] != null)
            p['payment_method'] as String,
      if (receivablesJson != null)
        for (final ar in receivablesJson)
          if ((ar as Map<String, dynamic>)['accounts_receivable_payments'] != null)
            for (final abono in (ar['accounts_receivable_payments'] as List<dynamic>))
              if ((abono as Map<String, dynamic>)['payment_method'] != null)
                abono['payment_method'] as String,
    }.toList();

    return ServiceOrderModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      orderNumber: json['order_number'] as String,
      cashRegisterId: json['cash_register_id'] as String,
      paidCashRegisterId: json['paid_cash_register_id'] as String?,
      customerId: json['customer_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      createdBy: json['created_by'] as String,
      status: json['status'] as String,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['final_price'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at'] as String) : null,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      customerName: customer?['full_name'] as String?,
      customerPhone: customer?['phone'] as String?,
      vehiclePlate: vehicle?['plate'] as String?,
      vehicleTypeId: vehicle?['vehicle_type_id'] as String?,
      workerName: workerName,
      serviceNames: serviceNames,
      paymentMethods: paymentMethods,
    );
  }
}
