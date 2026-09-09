import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserModel> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw Exception('Login failed');
    }
    
    final userData = await _client
        .from('users')
        .select('*, roles:role_id(name)')
        .eq('id', user.id)
        .single();

    userData['role_name'] = (userData['roles'] as Map<String, dynamic>)['name'];
    return UserModel.fromJson(userData);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final userData = await _client
          .from('users')
          .select('*, roles:role_id(name)')
          .eq('id', user.id)
          .single();

      userData['role_name'] = (userData['roles'] as Map<String, dynamic>)['name'];
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;
      return await getCurrentUser();
    });
  }
}
