import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  ServiceModel({
    required super.id,
    required super.companyId,
    super.categoryId,
    required super.name,
    super.description,
    required super.basePrice,
    super.estimatedDurationMin,
    required super.commissionPct,
    required super.applicableVehicleTypeIds,
    required super.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      basePrice: (json['base_price'] as num).toDouble(),
      estimatedDurationMin: json['estimated_duration_min'] as int?,
      commissionPct: (json['commission_pct'] as num?)?.toDouble() ?? 40.0,
      applicableVehicleTypeIds: (json['applicable_vehicle_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'estimated_duration_min': estimatedDurationMin,
      'commission_pct': commissionPct,
      'applicable_vehicle_types': applicableVehicleTypeIds,
      'is_active': isActive,
    };
  }
}
