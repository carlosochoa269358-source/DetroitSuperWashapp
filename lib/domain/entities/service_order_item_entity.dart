class ServiceOrderItemEntity {
  final String id;
  final String serviceOrderId;
  final String serviceId;
  final double basePrice;
  final double discountAmount;
  final double finalPrice;
  final double commissionPct;
  final double commissionAmount;

  // Solo lectura, poblado vía join.
  final String? serviceName;

  ServiceOrderItemEntity({
    required this.id,
    required this.serviceOrderId,
    required this.serviceId,
    required this.basePrice,
    required this.discountAmount,
    required this.finalPrice,
    required this.commissionPct,
    required this.commissionAmount,
    this.serviceName,
  });
}
