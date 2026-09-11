import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cash_register_entity.dart';
import '../entities/payment_method_total_entity.dart';
import '../entities/services_summary_entity.dart';

abstract class CashRegisterRepository {
  Future<Either<Failure, CashRegisterEntity?>> getAnyOpen(String companyId);
  Future<Either<Failure, double>> cashPaymentsTotal(String cashRegisterId);
  Future<Either<Failure, List<PaymentMethodTotal>>> paymentMethodTotals(String cashRegisterId);
  Future<Either<Failure, ServicesSummaryEntity>> servicesSummary(String cashRegisterId);
  Future<Either<Failure, CashRegisterEntity>> open({
    required String companyId,
    required String userId,
    required double openingAmount,
    Map<String, dynamic>? denominations,
  });
  Future<Either<Failure, void>> close({
    required String id,
    required String closedBy,
    required double expectedAmount,
    required double countedAmount,
    String? differenceReason,
  });
  Future<Either<Failure, List<CashRegisterEntity>>> getClosedHistory(String companyId);
}
