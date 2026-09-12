import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/user_management_datasource.dart';
import '../../data/repositories/user_management_repository_impl.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_provider.dart';

part 'user_management_provider.g.dart';

@riverpod
UserManagementDataSource userManagementDataSource(Ref ref) => UserManagementDataSource();

@riverpod
UserManagementRepositoryImpl userManagementRepository(Ref ref) {
  return UserManagementRepositoryImpl(ref.watch(userManagementDataSourceProvider));
}

@riverpod
Future<List<UserEntity>> companyUsers(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(userManagementRepositoryProvider);
  final result = await repo.getUsers(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

@riverpod
Future<List<RoleEntity>> availableRoles(Ref ref) async {
  final repo = ref.watch(userManagementRepositoryProvider);
  final result = await repo.getRoles();
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
