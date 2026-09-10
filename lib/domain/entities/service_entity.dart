class ServiceEntity {
  final String id;
  final String companyId;
  final String? categoryId;
  final String name;
  final String? description;
  final int? estimatedDurationMin;
  final double commissionPct;
  final Map<String, double> pricesByVehicleType;
  final bool isActive;

  ServiceEntity({
    required this.id,
    required this.companyId,
    this.categoryId,
    required this.name,
    this.description,
    this.estimatedDurationMin,
    required this.commissionPct,
    required this.pricesByVehicleType,
    required this.isActive,
  });

  double? priceFor(String vehicleTypeId) => pricesByVehicleType[vehicleTypeId];
}
