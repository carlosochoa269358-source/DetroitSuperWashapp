import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/service_order_item_datasource.dart';
import '../../data/repositories/service_order_item_repository_impl.dart';
import '../../domain/entities/service_order_item_entity.dart';

part 'service_order_item_provider.g.dart';

@riverpod
ServiceOrderItemDataSource serviceOrderItemDataSource(Ref ref) => ServiceOrderItemDataSource();

@riverpod
ServiceOrderItemRepositoryImpl serviceOrderItemRepository(Ref ref) {
  return ServiceOrderItemRepositoryImpl(ref.watch(serviceOrderItemDataSourceProvider));
}

@riverpod
Future<List<ServiceOrderItemEntity>> serviceOrderItems(Ref ref, String serviceOrderId) async {
  final repo = ref.watch(serviceOrderItemRepositoryProvider);
  final result = await repo.getByOrder(serviceOrderId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
