class ServiceEntity {
  final String id;
  final String companyId;
  final String? categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final int? estimatedDurationMin;
  final double commissionPct;
  final List<String> applicableVehicleTypeIds;
  final bool isActive;

  ServiceEntity({
    required this.id,
    required this.companyId,
    this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    this.estimatedDurationMin,
    required this.commissionPct,
    required this.applicableVehicleTypeIds,
    required this.isActive,
  });
}
