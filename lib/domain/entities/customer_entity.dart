class CustomerEntity {
  final String id;
  final String companyId;
  final String fullName;
  final String phone;
  final String? email;
  final String? notes;
  final bool isActive;
  final double totalSpent;
  final int visitCount;
  final DateTime? lastVisitAt;
  final DateTime createdAt;

  CustomerEntity({
    required this.id,
    required this.companyId,
    required this.fullName,
    required this.phone,
    this.email,
    this.notes,
    required this.isActive,
    required this.totalSpent,
    required this.visitCount,
    this.lastVisitAt,
    required this.createdAt,
  });
}
