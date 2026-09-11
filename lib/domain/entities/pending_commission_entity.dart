class PendingCommissionEntity {
  final String serviceOrderWorkerId;
  final String serviceOrderId;
  final String? orderNumber;
  final String? vehiclePlate;
  final DateTime serviceDate;
  final double orderFinalPrice;
  final double commissionAmount;

  const PendingCommissionEntity({
    required this.serviceOrderWorkerId,
    required this.serviceOrderId,
    this.orderNumber,
    this.vehiclePlate,
    required this.serviceDate,
    required this.orderFinalPrice,
    required this.commissionAmount,
  });
}
