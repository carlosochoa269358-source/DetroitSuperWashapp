import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/service_order_entity.dart';
import '../../domain/repositories/service_order_repository.dart';
import '../datasources/service_order_datasource.dart';

class ServiceOrderRepositoryImpl implements ServiceOrderRepository {
  final ServiceOrderDataSource dataSource;

  ServiceOrderRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ServiceOrderEntity>>> getByStatus({
    required String companyId,
    required String status,
  }) async {
    try {
      final result = await dataSource.getByStatus(companyId: companyId, status: status);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceOrderEntity>> getById(String id) async {
    try {
      final result = await dataSource.getById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final result = await dataSource.createOrderWithFirstService(
        companyId: companyId,
        cashRegisterId: cashRegisterId,
        customerId: customerId,
        vehicleId: vehicleId,
        createdBy: createdBy,
        employeeId: employeeId,
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
  Future<Either<Failure, void>> finalize(String orderId) async {
    try {
      await dataSource.finalize(orderId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancel({
    required String orderId,
    required String cancelledBy,
    required String reason,
  }) async {
    try {
      await dataSource.cancel(orderId: orderId, cancelledBy: cancelledBy, reason: reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> settlePayment({
    required String orderId,
    required String companyId,
    required String customerId,
    required String cashRegisterId,
    required String registeredBy,
    required double finalPrice,
    required double amountPaid,
    String? paymentMethod,
  }) async {
    try {
      await dataSource.settlePayment(
        orderId: orderId,
        companyId: companyId,
        customerId: customerId,
        cashRegisterId: cashRegisterId,
        registeredBy: registeredBy,
        finalPrice: finalPrice,
        amountPaid: amountPaid,
        paymentMethod: paymentMethod,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
