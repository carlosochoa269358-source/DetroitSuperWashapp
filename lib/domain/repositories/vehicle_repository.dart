import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<Either<Failure, List<VehicleEntity>>> getByCustomer(String customerId);
  Future<Either<Failure, VehicleEntity?>> getByPlate({required String companyId, required String plate});
  Future<Either<Failure, List<VehicleEntity>>> searchByPlate({required String companyId, required String query});
  Future<Either<Failure, List<VehicleEntity>>> getAllByCompany(String companyId);
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
  });
  Future<Either<Failure, VehicleEntity>> update({
    required String id,
    String? vehicleTypeId,
    required String plate,
    String? brand,
    String? model,
    String? color,
    int? year,
    String? notes,
  });
  Future<Either<Failure, void>> toggleActive({required String id, required bool isActive});

  /// Elimina la placa. Devuelve `Right(true)` si se borró de verdad, o
  /// `Right(false)` si en vez de eso se desactivó porque ya tenía historial
  /// de servicios asociado (no se puede borrar sin perder ese historial).
  Future<Either<Failure, bool>> delete(String id);
}
