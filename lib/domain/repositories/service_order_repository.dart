import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/service_order_entity.dart';

abstract class ServiceOrderRepository {
  Future<Either<Failure, List<ServiceOrderEntity>>> getByStatus({
    required String companyId,
    required String status,
    String? cashRegisterId,
  });
  Future<Either<Failure, List<ServiceOrderEntity>>> getCreatedInRegister(String cashRegisterId);
  Future<Either<Failure, List<ServiceOrderEntity>>> getPaidInRegister(String cashRegisterId);
  Future<Either<Failure, ServiceOrderEntity>> getById(String id);
  Future<Either<Failure, ServiceOrderEntity>> createOrderWithFirstService({
    required String companyId,
    required String cashRegisterId,
    required String customerId,
    required String vehicleId,
    required String createdBy,
    required String employeeId,
    required String serviceId,
    required double basePrice,
    required double discountAmount,
    required double commissionPct,
  });
  Future<Either<Failure, void>> finalize(String orderId);
  Future<Either<Failure, void>> cancel({
    required String orderId,
    required String cancelledBy,
    required String reason,
  });
  Future<Either<Failure, void>> settlePayment({
    required String orderId,
    required String companyId,
    required String customerId,
    required String cashRegisterId,
    required String registeredBy,
    required double finalPrice,
    required double amountPaid,
    String? paymentMethod,
  });
}
