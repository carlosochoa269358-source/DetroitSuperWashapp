import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/profit_report_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsDataSource dataSource;

  ReportsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, ProfitReportEntity>> getProfitReport({
    required String companyId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final result = await dataSource.getProfitReport(companyId: companyId, fromDate: fromDate, toDate: toDate);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
