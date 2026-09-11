import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/expense_category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDataSource dataSource;

  ExpenseRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ExpenseCategoryEntity>>> getCategories(String companyId) async {
    try {
      final result = await dataSource.getCategories(companyId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getByRegister(String cashRegisterId) async {
    try {
      final result = await dataSource.getByRegister(cashRegisterId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> create({
    required String companyId,
    required String categoryId,
    required String cashRegisterId,
    required String registeredBy,
    required String description,
    required double amount,
    required String paymentMethod,
    String? provider,
    String? notes,
  }) async {
    try {
      await dataSource.create(
        companyId: companyId,
        categoryId: categoryId,
        cashRegisterId: cashRegisterId,
        registeredBy: registeredBy,
        description: description,
        amount: amount,
        paymentMethod: paymentMethod,
        provider: provider,
        notes: notes,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> cancel({
    required String expenseId,
    required String cancelledBy,
    required String reason,
  }) async {
    try {
      await dataSource.cancel(expenseId: expenseId, cancelledBy: cancelledBy, reason: reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
