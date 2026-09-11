import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/service_order_item_entity.dart';
import '../../domain/repositories/service_order_item_repository.dart';
import '../datasources/service_order_item_datasource.dart';

class ServiceOrderItemRepositoryImpl implements ServiceOrderItemRepository {
  final ServiceOrderItemDataSource dataSource;

  ServiceOrderItemRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ServiceOrderItemEntity>>> getByOrder(String serviceOrderId) async {
    try {
      final result = await dataSource.getByOrder(serviceOrderId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceOrderItemEntity>> create({
    required String serviceOrderId,
    required String serviceId,
    required double basePrice,
    required double discountAmount,
    required double commissionPct,
  }) async {
    try {
      final result = await dataSource.create(
        serviceOrderId: serviceOrderId,
        serviceId: serviceId,
        basePrice: basePrice,
        discountAmount: discountAmount,
        commissionPct: commissionPct,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String itemId) async {
    try {
      await dataSource.delete(itemId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceOrderItemEntity>> updatePrice({
    required String itemId,
    required double basePrice,
    required double commissionPct,
    required double newFinalPrice,
  }) async {
    try {
      final result = await dataSource.updatePrice(
        itemId: itemId,
        basePrice: basePrice,
        commissionPct: commissionPct,
        newFinalPrice: newFinalPrice,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
