import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/role_entity.dart';
import '../entities/user_entity.dart';

abstract class UserManagementRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers(String companyId);
  Future<Either<Failure, List<RoleEntity>>> getRoles();
  Future<Either<Failure, void>> createUser({
    required String companyId,
    required String roleId,
    required String fullName,
    required String email,
    required String password,
    String? phone,
  });
  Future<Either<Failure, void>> toggleActive({required String id, required bool isActive});
}
