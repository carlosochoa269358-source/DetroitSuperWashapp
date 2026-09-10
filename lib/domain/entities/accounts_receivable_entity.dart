class AccountsReceivableEntity {
  final String id;
  final String companyId;
  final String serviceOrderId;
  final String customerId;
  final double originalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String status;

  // Solo lectura, poblados vía join.
  final String? customerName;
  final String? customerPhone;
  final String? orderNumber;
  final String? vehiclePlate;

  AccountsReceivableEntity({
    required this.id,
    required this.companyId,
    required this.serviceOrderId,
    required this.customerId,
    required this.originalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.orderNumber,
    this.vehiclePlate,
  });
}
