class ServiceCategoryEntity {
  final String id;
  final String companyId;
  final String name;
  final String? description;
  final String? colorHex;
  final int sortOrder;
  final bool isActive;

  ServiceCategoryEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    this.colorHex,
    required this.sortOrder,
    required this.isActive,
  });
}
