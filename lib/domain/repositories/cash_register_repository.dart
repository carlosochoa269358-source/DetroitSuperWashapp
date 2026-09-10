import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/cash_register_entity.dart';

abstract class CashRegisterRepository {
  Future<Either<Failure, CashRegisterEntity?>> getAnyOpen(String companyId);
  Future<Either<Failure, double>> cashPaymentsTotal(String cashRegisterId);
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
}
