class VehicleTypeEntity {
  final String id;
  final String? companyId;
  final String name;
  final String? icon;
  final int sortOrder;
  final bool isActive;

  VehicleTypeEntity({
    required this.id,
    this.companyId,
    required this.name,
    this.icon,
    required this.sortOrder,
    required this.isActive,
  });
}
