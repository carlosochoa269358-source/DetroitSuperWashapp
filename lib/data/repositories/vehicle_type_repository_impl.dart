import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/vehicle_type_entity.dart';
import '../../domain/repositories/vehicle_type_repository.dart';
import '../datasources/vehicle_type_datasource.dart';

class VehicleTypeRepositoryImpl implements VehicleTypeRepository {
  final VehicleTypeDataSource dataSource;

  VehicleTypeRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<VehicleTypeEntity>>> getAll(String companyId) async {
    try {
      final result = await dataSource.getAll(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleTypeEntity>> create({
    required String companyId,
    required String name,
    String? icon,
    int sortOrder = 0,
  }) async {
    try {
      final result = await dataSource.create(companyId: companyId, name: name, icon: icon, sortOrder: sortOrder);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleTypeEntity>> update({
    required String id,
    required String name,
    String? icon,
    required int sortOrder,
  }) async {
    try {
      final result = await dataSource.update(id: id, name: name, icon: icon, sortOrder: sortOrder);
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
