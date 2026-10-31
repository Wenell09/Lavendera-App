import '../entities/financial_report_entity.dart';

abstract class ReportRepository {
  Future<FinancialReportEntity> getFinancialReport({
    String? startDate,
    String? endDate,
    String? outletId,
    int page = 1,
    int limit = 10,
  });
}
