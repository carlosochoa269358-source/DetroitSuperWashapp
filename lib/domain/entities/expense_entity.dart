class ExpenseEntity {
  final String id;
  final String companyId;
  final String categoryId;
  final String? cashRegisterId;
  final String registeredBy;
  final String description;
  final double amount;
  final String paymentMethod;
  final String? provider;
  final DateTime expenseDate;
  final String? notes;
  final String status;
  final DateTime createdAt;

  // Solo lectura, poblado vía join.
  final String? categoryName;

  ExpenseEntity({
    required this.id,
    required this.companyId,
    required this.categoryId,
    this.cashRegisterId,
    required this.registeredBy,
    required this.description,
    required this.amount,
    required this.paymentMethod,
    this.provider,
    required this.expenseDate,
    this.notes,
    required this.status,
    required this.createdAt,
    this.categoryName,
  });
}
