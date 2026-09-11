import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/datasources/cash_register_datasource.dart';
import '../../data/repositories/cash_register_repository_impl.dart';
import '../../domain/entities/cash_register_entity.dart';
import 'auth_provider.dart';

part 'cash_register_provider.g.dart';

@riverpod
CashRegisterDataSource cashRegisterDataSource(Ref ref) => CashRegisterDataSource();

@riverpod
CashRegisterRepositoryImpl cashRegisterRepository(Ref ref) {
  return CashRegisterRepositoryImpl(ref.watch(cashRegisterDataSourceProvider));
}

/// El turno abierto más antiguo para la empresa, sin importar la fecha
/// (si hay uno de un día anterior sin cerrar, este es el que hay que cerrar primero).
@riverpod
Future<CashRegisterEntity?> anyOpenCashRegister(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return null;
  final repo = ref.watch(cashRegisterRepositoryProvider);
  final result = await repo.getAnyOpen(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (register) => register);
}

bool isTodayBogota(DateTime date) {
  final today = DateFormatter.todayBogota();
  return date.year == today.year && date.month == today.month && date.day == today.day;
}

/// El turno de HOY ya abierto (null si no hay ninguno, o si el abierto es de un día anterior).
@riverpod
Future<CashRegisterEntity?> openCashRegisterToday(Ref ref) async {
  final register = await ref.watch(anyOpenCashRegisterProvider.future);
  if (register == null || !register.isOpen) return null;
  if (!isTodayBogota(register.openingDate)) return null;
  return register;
}

@riverpod
Future<double> cashPaymentsTotal(Ref ref, String cashRegisterId) async {
  final repo = ref.watch(cashRegisterRepositoryProvider);
  final result = await repo.cashPaymentsTotal(cashRegisterId);
  return result.fold((failure) => throw Exception(failure.message), (total) => total);
}

/// Turnos cerrados de la empresa, para la pantalla de historial.
@riverpod
Future<List<CashRegisterEntity>> closedCashRegisters(Ref ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  final repo = ref.watch(cashRegisterRepositoryProvider);
  final result = await repo.getClosedHistory(user.companyId);
  return result.fold((failure) => throw Exception(failure.message), (list) => list);
}
