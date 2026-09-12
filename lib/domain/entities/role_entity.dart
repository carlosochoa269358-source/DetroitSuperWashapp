class RoleEntity {
  final String id;
  final String name;

  const RoleEntity({required this.id, required this.name});

  String get label {
    switch (name) {
      case 'admin_general':
        return 'Admin general';
      case 'admin_punto':
        return 'Admin de punto';
      case 'operador':
        return 'Operador';
      default:
        return name;
    }
  }
}
