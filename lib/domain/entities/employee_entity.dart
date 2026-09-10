class EmployeeEntity {
  final String id;
  final String companyId;
  final String fullName;
  final String? phone;
  final double commissionPct;
  final bool isActive;

  EmployeeEntity({
    required this.id,
    required this.companyId,
    required this.fullName,
    this.phone,
    required this.commissionPct,
    required this.isActive,
  });
}
