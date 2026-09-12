import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/reports_datasource.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/entities/profit_report_entity.dart';
import 'auth_provider.dart';

part 'reports_provider.g.dart';

@riverpod
ReportsDataSource reportsDataSource(Ref ref) => ReportsDataSource();

@riverpod
ReportsRepositoryImpl reportsRepository(Ref ref) {
  return ReportsRepositoryImpl(ref.watch(reportsDataSourceProvider));
}

@riverpod
Future<ProfitReportEntity> profitReport(Ref ref, DateTime fromDate, DateTime toDate) async {
  final user = ref.watch(authProvider).value;
  if (user == null) throw Exception('No autenticado');
  final repo = ref.watch(reportsRepositoryProvider);
  final result = await repo.getProfitReport(companyId: user.companyId, fromDate: fromDate, toDate: toDate);
  return result.fold((failure) => throw Exception(failure.message), (report) => report);
}
