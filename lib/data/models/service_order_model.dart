import '../../domain/entities/service_order_entity.dart';

class ServiceOrderModel extends ServiceOrderEntity {
  ServiceOrderModel({
    required super.id,
    required super.companyId,
    required super.orderNumber,
    required super.cashRegisterId,
    required super.customerId,
    required super.vehicleId,
    required super.serviceId,
    required super.createdBy,
    required super.status,
    required super.basePrice,
    required super.discountAmount,
    required super.finalPrice,
    required super.commissionPct,
    required super.commissionAmount,
    required super.paidAmount,
    required super.pendingAmount,
    required super.createdAt,
    super.finishedAt,
    super.paidAt,
    super.customerName,
    super.customerPhone,
    super.vehiclePlate,
    super.workerName,
    super.serviceName,
  });

  /// Soporta filas simples y filas con los recursos embebidos
  /// customers/vehicles/services/service_order_workers(employees).
  factory ServiceOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customers'] as Map<String, dynamic>?;
    final vehicle = json['vehicles'] as Map<String, dynamic>?;
    final service = json['services'] as Map<String, dynamic>?;
    final workers = json['service_order_workers'] as List<dynamic>?;
    String? workerName;
    if (workers != null && workers.isNotEmpty) {
      final employee = (workers.first as Map<String, dynamic>)['employees'] as Map<String, dynamic>?;
      workerName = employee?['full_name'] as String?;
    }

    return ServiceOrderModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      orderNumber: json['order_number'] as String,
      cashRegisterId: json['cash_register_id'] as String,
      customerId: json['customer_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      serviceId: json['service_id'] as String,
      createdBy: json['created_by'] as String,
      status: json['status'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['final_price'] as num).toDouble(),
      commissionPct: (json['commission_pct'] as num).toDouble(),
      commissionAmount: (json['commission_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at'] as String) : null,
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      customerName: customer?['full_name'] as String?,
      customerPhone: customer?['phone'] as String?,
      vehiclePlate: vehicle?['plate'] as String?,
      workerName: workerName,
      serviceName: service?['name'] as String?,
    );
  }
}
