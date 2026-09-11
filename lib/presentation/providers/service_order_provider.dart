import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/service_order_datasource.dart';
import '../../data/repositories/service_order_repository_impl.dart';
import '../../domain/entities/service_order_entity.dart';
import 'auth_provider.dart';
import 'cash_register_provider.dart';

part 'service_order_provider.g.dart';

@riverpod
ServiceOrderDataSource serviceOrderDataSource(Ref ref) => ServiceOrderDataSource();

@riverpod
ServiceOrderRepositoryImpl serviceOrderRepository(Ref ref) {
  return ServiceOrderRepositoryImpl(ref.watch(serviceOrderDataSourceProvider));
}

const _scopedByTurnoStatuses = {'new', 'finished', 'paid'};

/// Nuevas/Finalizadas/Pagadas solo muestran lo del turno abierto actual — al
/// cerrar el turno, esas listas se vacían (el dato queda archivado bajo ese
/// turno, ver [ordersCreatedInRegisterProvider]/[ordersPaidInRegisterProvider]).
/// "Por Cobrar" (fiados) no pasa por aquí — no se escopa por turno.
@riverpod
Future<List<ServiceOrderEntity>> serviceOrdersByStatus(Ref ref, String status) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(serviceOrderRepositoryProvider);

  String? cashRegisterId;
  if (_scopedByTurnoStatuses.contains(status)) {
    final register = await ref.watch(openCashRegisterTodayProvider.future);
    if (register == null) return [];
    cashRegisterId = register.id;
  }

  final result = await repo.getByStatus(companyId: user.companyId, status: status, cashRegisterId: cashRegisterId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

/// Órdenes creadas durante un turno (historial: "qué se atendió").
@riverpod
Future<List<ServiceOrderEntity>> ordersCreatedInRegister(Ref ref, String cashRegisterId) async {
  final repo = ref.watch(serviceOrderRepositoryProvider);
  final result = await repo.getCreatedInRegister(cashRegisterId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

/// Órdenes que terminaron de pagarse durante un turno (historial: "qué se cobró").
@riverpod
Future<List<ServiceOrderEntity>> ordersPaidInRegister(Ref ref, String cashRegisterId) async {
  final repo = ref.watch(serviceOrderRepositoryProvider);
  final result = await repo.getPaidInRegister(cashRegisterId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

@riverpod
Future<ServiceOrderEntity> serviceOrderById(Ref ref, String id) async {
  final repo = ref.watch(serviceOrderRepositoryProvider);
  final result = await repo.getById(id);
  return result.fold((failure) => throw Exception(failure.message), (order) => order);
}
