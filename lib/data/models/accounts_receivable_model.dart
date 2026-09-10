import '../../domain/entities/accounts_receivable_entity.dart';

class AccountsReceivableModel extends AccountsReceivableEntity {
  AccountsReceivableModel({
    required super.id,
    required super.companyId,
    required super.serviceOrderId,
    required super.customerId,
    required super.originalAmount,
    required super.paidAmount,
    required super.pendingAmount,
    required super.status,
    super.customerName,
    super.customerPhone,
    super.orderNumber,
    super.vehiclePlate,
  });

  factory AccountsReceivableModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customers'] as Map<String, dynamic>?;
    final order = json['service_orders'] as Map<String, dynamic>?;
    final vehicle = order?['vehicles'] as Map<String, dynamic>?;

    return AccountsReceivableModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      serviceOrderId: json['service_order_id'] as String,
      customerId: json['customer_id'] as String,
      originalAmount: (json['original_amount'] as num).toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      pendingAmount: (json['pending_amount'] as num).toDouble(),
      status: json['status'] as String,
      customerName: customer?['full_name'] as String?,
      customerPhone: customer?['phone'] as String?,
      orderNumber: order?['order_number'] as String?,
      vehiclePlate: vehicle?['plate'] as String?,
    );
  }
}
