import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/employee_settlement_datasource.dart';
import '../../data/repositories/employee_settlement_repository_impl.dart';
import '../../domain/entities/employee_pending_summary_entity.dart';
import '../../domain/entities/turno_settlement_entity.dart';

part 'employee_settlement_provider.g.dart';

@riverpod
EmployeeSettlementDataSource employeeSettlementDataSource(Ref ref) => EmployeeSettlementDataSource();

@riverpod
EmployeeSettlementRepositoryImpl employeeSettlementRepository(Ref ref) {
  return EmployeeSettlementRepositoryImpl(ref.watch(employeeSettlementDataSourceProvider));
}

/// Cuánto se le debe a cada trabajador activo (comisión de órdenes ya
/// pagadas, sin liquidar), para la tarjeta de Liquidación en Caja.
@riverpod
Future<List<EmployeePendingSummaryEntity>> employeePendingSummary(Ref ref) async {
  final repo = ref.watch(employeeSettlementRepositoryProvider);
  final result = await repo.getPendingSummary();
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}

/// Liquidaciones ya pagadas durante un turno (para mostrarlas en Caja, no
/// solo restarlas silenciosamente).
@riverpod
Future<List<TurnoSettlementEntity>> turnoSettlements(Ref ref, String cashRegisterId) async {
  final repo = ref.watch(employeeSettlementRepositoryProvider);
  final result = await repo.getSettlementsForRegister(cashRegisterId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
