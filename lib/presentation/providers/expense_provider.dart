import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/expense_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense_category_entity.dart';
import '../../domain/entities/expense_entity.dart';
import 'auth_provider.dart';

part 'expense_provider.g.dart';

@riverpod
ExpenseDataSource expenseDataSource(Ref ref) => ExpenseDataSource();

@riverpod
ExpenseRepositoryImpl expenseRepository(Ref ref) {
  return ExpenseRepositoryImpl(ref.watch(expenseDataSourceProvider));
}

@riverpod
Future<List<ExpenseCategoryEntity>> expenseCategories(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(expenseRepositoryProvider);
  final result = await repo.getCategories(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

@riverpod
Future<List<ExpenseEntity>> expensesByRegister(Ref ref, String cashRegisterId) async {
  final repo = ref.watch(expenseRepositoryProvider);
  final result = await repo.getByRegister(cashRegisterId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
