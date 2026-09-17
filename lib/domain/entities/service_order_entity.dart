class ServiceOrderEntity {
  final String id;
  final String companyId;
  final String orderNumber;
  final String cashRegisterId;
  final String? paidCashRegisterId;
  final String customerId;
  final String vehicleId;
  final String createdBy;
  final String status;
  final double discountAmount;
  final double finalPrice;
  final double commissionAmount;
  final double paidAmount;
  final double pendingAmount;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final DateTime? paidAt;

  // Campos de solo lectura para mostrar en listas (poblados vía join al consultar).
  final String? customerName;
  final String? customerPhone;
  final String? vehiclePlate;
  final String? vehicleTypeId;
  final String? workerName;
  final List<String> serviceNames;
  /// Métodos de pago usados para saldar la orden (puede haber más de uno si
  /// se pagó parte de contado y el resto se abonó después como fiado).
  final List<String> paymentMethods;

  ServiceOrderEntity({
    required this.id,
    required this.companyId,
    required this.orderNumber,
    required this.cashRegisterId,
    this.paidCashRegisterId,
    required this.customerId,
    required this.vehicleId,
    required this.createdBy,
    required this.status,
    required this.discountAmount,
    required this.finalPrice,
    required this.commissionAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.createdAt,
    this.finishedAt,
    this.paidAt,
    this.customerName,
    this.customerPhone,
    this.vehiclePlate,
    this.vehicleTypeId,
    this.workerName,
    this.serviceNames = const [],
    this.paymentMethods = const [],
  });
}
