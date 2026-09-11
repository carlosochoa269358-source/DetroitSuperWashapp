import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/cash_register_entity.dart';
import '../../domain/repositories/cash_register_repository.dart';
import '../datasources/cash_register_datasource.dart';

class CashRegisterRepositoryImpl implements CashRegisterRepository {
  final CashRegisterDataSource dataSource;

  CashRegisterRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, CashRegisterEntity?>> getAnyOpen(String companyId) async {
    try {
      final result = await dataSource.getAnyOpen(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> cashPaymentsTotal(String cashRegisterId) async {
    try {
      final result = await dataSource.cashPaymentsTotal(cashRegisterId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CashRegisterEntity>> open({
    required String companyId,
    required String userId,
    required double openingAmount,
    Map<String, dynamic>? denominations,
  }) async {
    try {
      final result = await dataSource.open(
        companyId: companyId,
        userId: userId,
        openingAmount: openingAmount,
        denominations: denominations,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> close({
    required String id,
    required String closedBy,
    required double expectedAmount,
    required double countedAmount,
    String? differenceReason,
  }) async {
    try {
      await dataSource.close(
        id: id,
        closedBy: closedBy,
        expectedAmount: expectedAmount,
        countedAmount: countedAmount,
        differenceReason: differenceReason,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<CashRegisterEntity>>> getClosedHistory(String companyId) async {
    try {
      final result = await dataSource.getClosedHistory(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
