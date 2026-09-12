import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/role_entity.dart';
import '../models/user_model.dart';

class UserManagementDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<UserModel>> getUsers(String companyId) async {
    final data = await _client
        .from('users')
        .select('*, roles:role_id(name)')
        .eq('company_id', companyId)
        .order('full_name');
    return (data as List).map((row) {
      final map = row as Map<String, dynamic>;
      map['role_name'] = (map['roles'] as Map<String, dynamic>?)?['name'];
      return UserModel.fromJson(map);
    }).toList();
  }

  Future<List<RoleEntity>> getRoles() async {
    final data = await _client.from('roles').select('id, name').order('name');
    return (data as List).map((r) => RoleEntity(id: r['id'] as String, name: r['name'] as String)).toList();
  }

  /// Crea un usuario con acceso a la app: cuenta de login (Supabase Auth) +
  /// su perfil (empresa, rol, nombre) en la tabla users.
  ///
  /// `signUp` reemplaza la sesión activa por la del usuario nuevo — por eso
  /// se guarda el refresh token del admin ANTES de llamarlo y se restaura
  /// justo después, ANTES de insertar el perfil (el insert necesita
  /// ejecutarse como el admin, porque las políticas de la tabla exigen que
  /// quien inserta ya sea admin_general — el usuario recién creado todavía
  /// no tiene perfil propio para cumplir esa condición).
  Future<void> createUser({
    required String companyId,
    required String roleId,
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final adminSession = _client.auth.currentSession;
    final adminRefreshToken = adminSession?.refreshToken;
    if (adminRefreshToken == null) {
      throw Exception('Tu sesión no es válida. Vuelve a iniciar sesión e inténtalo de nuevo.');
    }

    final response = await _client.auth.signUp(email: email, password: password);
    final newUserId = response.user?.id;
    if (newUserId == null) {
      throw Exception('No se pudo crear el usuario en Supabase.');
    }

    await _client.auth.setSession(adminRefreshToken);

    await _client.from('users').insert({
      'id': newUserId,
      'company_id': companyId,
      'role_id': roleId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'is_active': true,
    });
  }

  Future<void> toggleActive({required String id, required bool isActive}) async {
    await _client.from('users').update({'is_active': isActive}).eq('id', id);
  }
}
