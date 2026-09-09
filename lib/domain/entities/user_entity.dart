class UserEntity {
  final String id;
  final String companyId;
  final String roleId;
  final String roleName; 
  final String fullName;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.companyId,
    required this.roleId,
    required this.roleName,
    required this.fullName,
    this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAdminGeneral => roleName == 'admin_general';
  bool get isAdminPunto => roleName == 'admin_punto';
  bool get isOperador => roleName == 'operador';
}
