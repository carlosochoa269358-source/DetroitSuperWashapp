import '../../domain/entities/vehicle_type_entity.dart';

class VehicleTypeModel extends VehicleTypeEntity {
  VehicleTypeModel({
    required super.id,
    super.companyId,
    required super.name,
    super.icon,
    required super.sortOrder,
    required super.isActive,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String?,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'icon': icon,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
