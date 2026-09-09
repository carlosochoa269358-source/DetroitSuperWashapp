import '../../domain/entities/company_entity.dart';

class CompanyModel extends CompanyEntity {
  CompanyModel({
    required super.id,
    required super.document,
    required super.name,
    super.address,
    super.phone,
    required super.isActive,
    required super.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      document: json['document'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document': document,
      'name': name,
      'address': address,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
