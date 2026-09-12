import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../datasources/user_management_datasource.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final UserManagementDataSource dataSource;

  UserManagementRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers(String companyId) async {
    try {
      final result = await dataSource.getUsers(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RoleEntity>>> getRoles() async {
    try {
      final result = await dataSource.getRoles();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUser({
    required String companyId,
    required String roleId,
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      await dataSource.createUser(
        companyId: companyId,
        roleId: roleId,
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> toggleActive({required String id, required bool isActive}) async {
    try {
      await dataSource.toggleActive(id: id, isActive: isActive);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
