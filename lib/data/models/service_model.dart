import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  ServiceModel({
    required super.id,
    required super.companyId,
    super.categoryId,
    required super.name,
    super.description,
    super.estimatedDurationMin,
    required super.commissionPct,
    required super.pricesByVehicleType,
    required super.isActive,
  });

  /// Espera que la fila venga con el recurso embebido `service_prices(vehicle_type_id, price)`,
  /// tal como lo devuelve `.select('*, service_prices(vehicle_type_id, price)')`.
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final pricesRaw = json['service_prices'] as List<dynamic>? ?? const [];
    final prices = <String, double>{
      for (final row in pricesRaw)
        (row as Map<String, dynamic>)['vehicle_type_id'] as String: (row['price'] as num).toDouble(),
    };

    return ServiceModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      estimatedDurationMin: json['estimated_duration_min'] as int?,
      commissionPct: (json['commission_pct'] as num?)?.toDouble() ?? 40.0,
      pricesByVehicleType: prices,
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
      'estimated_duration_min': estimatedDurationMin,
      'commission_pct': commissionPct,
      'is_active': isActive,
    };
  }
}
