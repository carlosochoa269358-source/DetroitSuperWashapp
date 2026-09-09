import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  VehicleModel({
    required super.id,
    required super.companyId,
    required super.customerId,
    super.vehicleTypeId,
    required super.plate,
    super.brand,
    super.model,
    super.color,
    super.year,
    super.notes,
    required super.isActive,
    required super.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      customerId: json['customer_id'] as String,
      vehicleTypeId: json['vehicle_type_id'] as String?,
      plate: json['plate'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      year: json['year'] as int?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'customer_id': customerId,
      'vehicle_type_id': vehicleTypeId,
      'plate': plate,
      'brand': brand,
      'model': model,
      'color': color,
      'year': year,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
