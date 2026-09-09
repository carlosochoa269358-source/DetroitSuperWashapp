import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/vehicle_type_entity.dart';

abstract class VehicleTypeRepository {
  Future<Either<Failure, List<VehicleTypeEntity>>> getAll(String companyId);
  Future<Either<Failure, VehicleTypeEntity>> create({
    required String companyId,
    required String name,
    String? icon,
    int sortOrder = 0,
  });
  Future<Either<Failure, VehicleTypeEntity>> update({
    required String id,
    required String name,
    String? icon,
    required int sortOrder,
  });
  Future<Either<Failure, void>> toggleActive({required String id, required bool isActive});
}
