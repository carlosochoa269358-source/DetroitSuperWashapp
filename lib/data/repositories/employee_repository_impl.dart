import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeDataSource dataSource;

  EmployeeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getAll(String companyId) async {
    try {
      final result = await dataSource.getAll(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> create({
    required String companyId,
    required String fullName,
    String? phone,
    required double commissionPct,
  }) async {
    try {
      final result = await dataSource.create(
        companyId: companyId,
        fullName: fullName,
        phone: phone,
        commissionPct: commissionPct,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> update({
    required String id,
    required String fullName,
    String? phone,
    required double commissionPct,
  }) async {
    try {
      final result = await dataSource.update(
        id: id,
        fullName: fullName,
        phone: phone,
        commissionPct: commissionPct,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
