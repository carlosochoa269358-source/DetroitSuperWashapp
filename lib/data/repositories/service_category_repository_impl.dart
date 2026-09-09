import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/service_category_entity.dart';
import '../../domain/repositories/service_category_repository.dart';
import '../datasources/service_category_datasource.dart';

class ServiceCategoryRepositoryImpl implements ServiceCategoryRepository {
  final ServiceCategoryDataSource dataSource;

  ServiceCategoryRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ServiceCategoryEntity>>> getAll(String companyId) async {
    try {
      final result = await dataSource.getAll(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceCategoryEntity>> create({
    required String companyId,
    required String name,
    String? description,
    String? colorHex,
    int sortOrder = 0,
  }) async {
    try {
      final result = await dataSource.create(
        companyId: companyId,
        name: name,
        description: description,
        colorHex: colorHex,
        sortOrder: sortOrder,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceCategoryEntity>> update({
    required String id,
    required String name,
    String? description,
    String? colorHex,
    required int sortOrder,
  }) async {
    try {
      final result = await dataSource.update(
        id: id,
        name: name,
        description: description,
        colorHex: colorHex,
        sortOrder: sortOrder,
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
