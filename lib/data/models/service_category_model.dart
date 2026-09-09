import '../../domain/entities/service_category_entity.dart';

class ServiceCategoryModel extends ServiceCategoryEntity {
  ServiceCategoryModel({
    required super.id,
    required super.companyId,
    required super.name,
    super.description,
    super.colorHex,
    required super.sortOrder,
    required super.isActive,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      colorHex: json['color_hex'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'description': description,
      'color_hex': colorHex,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
