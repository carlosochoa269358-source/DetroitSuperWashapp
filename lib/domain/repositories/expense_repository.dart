import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/expense_category_entity.dart';
import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseCategoryEntity>>> getCategories(String companyId);
  Future<Either<Failure, List<ExpenseEntity>>> getByRegister(String cashRegisterId);
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
  });
  Future<Either<Failure, void>> cancel({
    required String expenseId,
    required String cancelledBy,
    required String reason,
  });
}
