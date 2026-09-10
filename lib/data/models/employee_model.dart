import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  EmployeeModel({
    required super.id,
    required super.companyId,
    required super.fullName,
    super.phone,
    required super.commissionPct,
    required super.isActive,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      commissionPct: (json['commission_pct'] as num?)?.toDouble() ?? 40.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'full_name': fullName,
      'phone': phone,
      'commission_pct': commissionPct,
      'is_active': isActive,
    };
  }
}
