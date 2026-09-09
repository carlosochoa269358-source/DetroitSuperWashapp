import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleDataSource dataSource;

  VehicleRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<VehicleEntity>>> getByCustomer(String customerId) async {
    try {
      final result = await dataSource.getByCustomer(customerId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity?>> getByPlate({required String companyId, required String plate}) async {
    try {
      final result = await dataSource.getByPlate(companyId: companyId, plate: plate);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> create({
    required String companyId,
    required String customerId,
    String? vehicleTypeId,
    required String plate,
    String? brand,
    String? model,
    String? color,
    int? year,
    String? notes,
  }) async {
    try {
      final result = await dataSource.create(
        companyId: companyId,
        customerId: customerId,
        vehicleTypeId: vehicleTypeId,
        plate: plate,
        brand: brand,
        model: model,
        color: color,
        year: year,
        notes: notes,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VehicleEntity>> update({
    required String id,
    String? vehicleTypeId,
    required String plate,
    String? brand,
    String? model,
    String? color,
    int? year,
    String? notes,
  }) async {
    try {
      final result = await dataSource.update(
        id: id,
        vehicleTypeId: vehicleTypeId,
        plate: plate,
        brand: brand,
        model: model,
        color: color,
        year: year,
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
}
