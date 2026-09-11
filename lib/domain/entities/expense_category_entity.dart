class ExpenseCategoryEntity {
  final String id;
  final String? parentId;
  final String name;
  final String expenseType;
  final bool isActive;

  ExpenseCategoryEntity({
    required this.id,
    this.parentId,
    required this.name,
    required this.expenseType,
    required this.isActive,
  });
}
