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
  }) async {
    try {
      final result = await dataSource.create(
        companyId: companyId,
        cashRegisterId: cashRegisterId,
        customerId: customerId,
        vehicleId: vehicleId,
        serviceId: serviceId,
        createdBy: createdBy,
        basePrice: basePrice,
        discountAmount: discountAmount,
        commissionPct: commissionPct,
        employeeId: employeeId,
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
