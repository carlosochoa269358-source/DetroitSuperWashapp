import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/service_order_entity.dart';

abstract class ServiceOrderRepository {
  Future<Either<Failure, List<ServiceOrderEntity>>> getByStatus({
    required String companyId,
    required String status,
  });
  Future<Either<Failure, ServiceOrderEntity>> create({
    required String companyId,
    required String cashRegisterId,
    required String customerId,
    required String vehicleId,
    required String serviceId,
    required String createdBy,
    required double basePrice,
    required double discountAmount,
    required double commissionPct,
    required String employeeId,
  });
  Future<Either<Failure, void>> finalize(String orderId);
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
