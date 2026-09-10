import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/accounts_receivable_entity.dart';
import '../../domain/repositories/accounts_receivable_repository.dart';
import '../datasources/accounts_receivable_datasource.dart';

class AccountsReceivableRepositoryImpl implements AccountsReceivableRepository {
  final AccountsReceivableDataSource dataSource;

  AccountsReceivableRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<AccountsReceivableEntity>>> getOpen(String companyId) async {
    try {
      final result = await dataSource.getOpen(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerAbono({
    required String accountsReceivableId,
    required String cashRegisterId,
    required String registeredBy,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      await dataSource.registerAbono(
        accountsReceivableId: accountsReceivableId,
        cashRegisterId: cashRegisterId,
        registeredBy: registeredBy,
        amount: amount,
        paymentMethod: paymentMethod,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
