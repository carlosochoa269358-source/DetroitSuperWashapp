import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  CustomerModel({
    required super.id,
    required super.companyId,
    required super.fullName,
    required super.phone,
    super.email,
    super.notes,
    required super.isActive,
    required super.totalSpent,
    required super.visitCount,
    super.lastVisitAt,
    required super.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      visitCount: json['visit_count'] as int? ?? 0,
      lastVisitAt: json['last_visit_at'] != null ? DateTime.parse(json['last_visit_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
