import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/service_entity.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<ServiceEntity>>> getAll(String companyId);
  Future<Either<Failure, ServiceEntity>> create({
    required String companyId,
    String? categoryId,
    required String name,
    String? description,
    int? estimatedDurationMin,
    required double commissionPct,
    required Map<String, double> pricesByVehicleType,
  });
  Future<Either<Failure, ServiceEntity>> update({
    required String id,
    String? categoryId,
    required String name,
    String? description,
    int? estimatedDurationMin,
    required double commissionPct,
    required Map<String, double> pricesByVehicleType,
  });
  Future<Either<Failure, void>> toggleActive({required String id, required bool isActive});
}
