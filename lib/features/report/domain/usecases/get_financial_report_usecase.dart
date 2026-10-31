import '../entities/financial_report_entity.dart';
import '../repositories/report_repository.dart';

class GetFinancialReportUsecase {
  final ReportRepository repository;

  GetFinancialReportUsecase(this.repository);

  Future<FinancialReportEntity> call({
    String? startDate,
    String? endDate,
    String? outletId,
    int page = 1,
    int limit = 10,
  }) {
    return repository.getFinancialReport(
      startDate: startDate,
      endDate: endDate,
      outletId: outletId,
      page: page,
      limit: limit,
    );
  }
}
