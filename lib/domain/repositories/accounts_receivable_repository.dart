import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/accounts_receivable_entity.dart';

abstract class AccountsReceivableRepository {
  Future<Either<Failure, List<AccountsReceivableEntity>>> getOpen(String companyId);
  Future<Either<Failure, void>> registerAbono({
    required String accountsReceivableId,
    required String cashRegisterId,
    required String registeredBy,
    required double amount,
    required String paymentMethod,
  });
}
