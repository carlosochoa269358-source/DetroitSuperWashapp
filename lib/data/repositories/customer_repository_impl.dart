import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerDataSource dataSource;

  CustomerRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CustomerEntity>>> search({required String companyId, String? query}) async {
    try {
      final result = await dataSource.search(companyId: companyId, query: query);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getById(String id) async {
    try {
      final result = await dataSource.getById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity?>> getByPhone({required String companyId, required String phone}) async {
    try {
      final result = await dataSource.getByPhone(companyId: companyId, phone: phone);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> create({
    required String companyId,
    required String fullName,
    required String phone,
    String? email,
    String? notes,
  }) async {
    try {
      final result = await dataSource.create(
        companyId: companyId,
        fullName: fullName,
        phone: phone,
        email: email,
        notes: notes,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> update({
    required String id,
    required String fullName,
    required String phone,
    String? email,
    String? notes,
  }) async {
    try {
      final result = await dataSource.update(
        id: id,
        fullName: fullName,
        phone: phone,
        email: email,
        notes: notes,
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

  @override
  Future<Either<Failure, bool>> delete(String id) async {
    try {
      final deleted = await dataSource.delete(id);
      if (!deleted) {
        return Left(ServerFailure('No se pudo eliminar el cliente (sin permisos o ya no existe)'));
      }
      return const Right(true);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        try {
          await dataSource.toggleActive(id: id, isActive: false);
          return const Right(false);
        } catch (e2) {
          return Left(ServerFailure(e2.toString()));
        }
      }
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
