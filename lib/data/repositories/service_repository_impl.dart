import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_datasource.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceDataSource dataSource;

  ServiceRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ServiceEntity>>> getAll(String companyId) async {
    try {
      final result = await dataSource.getAll(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> create({
    required String companyId,
    String? categoryId,
    required String name,
    String? description,
    required double basePrice,
    int? estimatedDurationMin,
    required double commissionPct,
    required List<String> applicableVehicleTypeIds,
  }) async {
    try {
      final result = await dataSource.create(
        companyId: companyId,
        categoryId: categoryId,
        name: name,
        description: description,
        basePrice: basePrice,
        estimatedDurationMin: estimatedDurationMin,
        commissionPct: commissionPct,
        applicableVehicleTypeIds: applicableVehicleTypeIds,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> update({
    required String id,
    String? categoryId,
    required String name,
    String? description,
    required double basePrice,
    int? estimatedDurationMin,
    required double commissionPct,
    required List<String> applicableVehicleTypeIds,
  }) async {
    try {
      final result = await dataSource.update(
        id: id,
        categoryId: categoryId,
        name: name,
        description: description,
        basePrice: basePrice,
        estimatedDurationMin: estimatedDurationMin,
        commissionPct: commissionPct,
        applicableVehicleTypeIds: applicableVehicleTypeIds,
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
