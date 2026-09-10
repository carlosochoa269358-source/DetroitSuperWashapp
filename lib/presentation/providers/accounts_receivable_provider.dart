import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/accounts_receivable_datasource.dart';
import '../../data/repositories/accounts_receivable_repository_impl.dart';
import '../../domain/entities/accounts_receivable_entity.dart';
import 'auth_provider.dart';

part 'accounts_receivable_provider.g.dart';

@riverpod
AccountsReceivableDataSource accountsReceivableDataSource(Ref ref) => AccountsReceivableDataSource();

@riverpod
AccountsReceivableRepositoryImpl accountsReceivableRepository(Ref ref) {
  return AccountsReceivableRepositoryImpl(ref.watch(accountsReceivableDataSourceProvider));
}

@riverpod
Future<List<AccountsReceivableEntity>> openAccountsReceivable(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(accountsReceivableRepositoryProvider);
  final result = await repo.getOpen(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
