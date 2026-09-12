import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/profit_report_entity.dart';

abstract class ReportsRepository {
  Future<Either<Failure, ProfitReportEntity>> getProfitReport({
    required String companyId,
    required DateTime fromDate,
    required DateTime toDate,
  });
}
