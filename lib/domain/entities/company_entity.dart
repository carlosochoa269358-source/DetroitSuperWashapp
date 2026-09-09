class CompanyEntity {
  final String id;
  final String document;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  CompanyEntity({
    required this.id,
    required this.document,
    required this.name,
    this.address,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });
}
