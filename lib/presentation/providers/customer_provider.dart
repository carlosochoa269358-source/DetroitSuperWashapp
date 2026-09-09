import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/customer_datasource.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer_entity.dart';
import 'auth_provider.dart';

part 'customer_provider.g.dart';

@riverpod
CustomerDataSource customerDataSource(Ref ref) => CustomerDataSource();

@riverpod
CustomerRepositoryImpl customerRepository(Ref ref) {
  return CustomerRepositoryImpl(ref.watch(customerDataSourceProvider));
}

@riverpod
Future<List<CustomerEntity>> customerSearch(Ref ref, String? query) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(customerRepositoryProvider);
  final result = await repo.search(companyId: user.companyId, query: query);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

@riverpod
Future<CustomerEntity> customerById(Ref ref, String id) async {
  final repo = ref.watch(customerRepositoryProvider);
  final result = await repo.getById(id);
  return result.fold((failure) => throw Exception(failure.message), (customer) => customer);
}
