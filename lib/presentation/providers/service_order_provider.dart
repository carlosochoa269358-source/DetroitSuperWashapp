import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/service_order_datasource.dart';
import '../../data/repositories/service_order_repository_impl.dart';
import '../../domain/entities/service_order_entity.dart';
import 'auth_provider.dart';

part 'service_order_provider.g.dart';

@riverpod
ServiceOrderDataSource serviceOrderDataSource(Ref ref) => ServiceOrderDataSource();

@riverpod
ServiceOrderRepositoryImpl serviceOrderRepository(Ref ref) {
  return ServiceOrderRepositoryImpl(ref.watch(serviceOrderDataSourceProvider));
}

@riverpod
Future<List<ServiceOrderEntity>> serviceOrdersByStatus(Ref ref, String status) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(serviceOrderRepositoryProvider);
  final result = await repo.getByStatus(companyId: user.companyId, status: status);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
