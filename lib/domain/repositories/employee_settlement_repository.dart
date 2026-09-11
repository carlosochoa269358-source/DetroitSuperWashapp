import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/employee_pending_summary_entity.dart';
import '../entities/turno_settlement_entity.dart';

abstract class EmployeeSettlementRepository {
  Future<Either<Failure, List<EmployeePendingSummaryEntity>>> getPendingSummary();
  Future<Either<Failure, List<TurnoSettlementEntity>>> getSettlementsForRegister(String cashRegisterId);
  Future<Either<Failure, void>> liquidateAllPending({
    required String companyId,
    required String employeeId,
    required String cashRegisterId,
    required String settledBy,
    required double commissionPct,
    required String paymentMethod,
    String? notes,
  });
}
