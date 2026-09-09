import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<CustomerEntity>>> search({required String companyId, String? query});
  Future<Either<Failure, CustomerEntity>> getById(String id);
  Future<Either<Failure, CustomerEntity>> create({
    required String companyId,
    required String fullName,
    required String phone,
    String? email,
    String? notes,
  });
  Future<Either<Failure, CustomerEntity>> update({
    required String id,
    required String fullName,
    required String phone,
    String? email,
    String? notes,
  });
  Future<Either<Failure, void>> toggleActive({required String id, required bool isActive});
}
