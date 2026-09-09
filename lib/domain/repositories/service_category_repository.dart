import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/service_category_entity.dart';

abstract class ServiceCategoryRepository {
  Future<Either<Failure, List<ServiceCategoryEntity>>> getAll(String companyId);
  Future<Either<Failure, ServiceCategoryEntity>> create({
    required String companyId,
    required String name,
    String? description,
    String? colorHex,
    int sortOrder = 0,
  });
  Future<Either<Failure, ServiceCategoryEntity>> update({
    required String id,
    required String name,
    String? description,
    String? colorHex,
    required int sortOrder,
  });
  Future<Either<Failure, void>> toggleActive({required String id, required bool isActive});
}
