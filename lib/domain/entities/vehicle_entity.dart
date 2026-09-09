class VehicleEntity {
  final String id;
  final String companyId;
  final String customerId;
  final String? vehicleTypeId;
  final String plate;
  final String? brand;
  final String? model;
  final String? color;
  final int? year;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;

  VehicleEntity({
    required this.id,
    required this.companyId,
    required this.customerId,
    this.vehicleTypeId,
    required this.plate,
    this.brand,
    this.model,
    this.color,
    this.year,
    this.notes,
    required this.isActive,
    required this.createdAt,
  });
}
