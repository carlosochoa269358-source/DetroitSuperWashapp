import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/service_order_item_entity.dart';

abstract class ServiceOrderItemRepository {
  Future<Either<Failure, List<ServiceOrderItemEntity>>> getByOrder(String serviceOrderId);
  Future<Either<Failure, ServiceOrderItemEntity>> create({
    required String serviceOrderId,
    required String serviceId,
    required double basePrice,
    required double discountAmount,
    required double commissionPct,
  });
  Future<Either<Failure, void>> delete(String itemId);
  Future<Either<Failure, ServiceOrderItemEntity>> updatePrice({
    required String itemId,
    required double basePrice,
    required double commissionPct,
    required double newFinalPrice,
  });
}
