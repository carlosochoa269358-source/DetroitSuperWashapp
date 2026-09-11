import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/employee_pending_summary_entity.dart';
import '../../domain/entities/turno_settlement_entity.dart';
import '../../domain/repositories/employee_settlement_repository.dart';
import '../datasources/employee_settlement_datasource.dart';

class EmployeeSettlementRepositoryImpl implements EmployeeSettlementRepository {
  final EmployeeSettlementDataSource dataSource;

  EmployeeSettlementRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<EmployeePendingSummaryEntity>>> getPendingSummary() async {
    try {
      final result = await dataSource.getPendingSummary();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TurnoSettlementEntity>>> getSettlementsForRegister(String cashRegisterId) async {
    try {
      final result = await dataSource.getSettlementsForRegister(cashRegisterId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> liquidateAllPending({
    required String companyId,
    required String employeeId,
    required String cashRegisterId,
    required String settledBy,
    required double commissionPct,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      await dataSource.liquidateAllPending(
        companyId: companyId,
        employeeId: employeeId,
        cashRegisterId: cashRegisterId,
        settledBy: settledBy,
        commissionPct: commissionPct,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
