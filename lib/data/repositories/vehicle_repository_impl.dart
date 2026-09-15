import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  Future<Either<Failure, List<VehicleEntity>>> getAllByCompany(String companyId) async {
    try {
      final result = await dataSource.getAllByCompany(companyId);
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
  Future<Either<Failure, VehicleEntity?>> getByPlateAny({required String companyId, required String plate}) async {
    try {
      final result = await dataSource.getByPlateAny(companyId: companyId, plate: plate);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> searchByPlate({required String companyId, required String query}) async {
    try {
      final result = await dataSource.searchByPlate(companyId: companyId, query: query);
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

  @override
  Future<Either<Failure, void>> transferToCustomer({required String vehicleId, required String newCustomerId}) async {
    try {
      await dataSource.transferToCustomer(vehicleId: vehicleId, newCustomerId: newCustomerId);
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
        return Left(ServerFailure('No se pudo eliminar la placa (sin permisos o ya no existe)'));
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
