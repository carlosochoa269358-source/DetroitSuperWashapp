import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/employee_entity.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, List<EmployeeEntity>>> getAll(String companyId);
  Future<Either<Failure, EmployeeEntity>> create({
    required String companyId,
    required String fullName,
    String? phone,
    required double commissionPct,
  });
  Future<Either<Failure, EmployeeEntity>> update({
    required String id,
    required String fullName,
    String? phone,
    required double commissionPct,
  });
  Future<Either<Failure, void>> toggleActive({required String id, required bool isActive});
}
