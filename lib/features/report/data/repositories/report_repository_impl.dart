import '../../domain/entities/financial_report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FinancialReportEntity> getFinancialReport({
    String? startDate,
    String? endDate,
    String? outletId,
    int page = 1,
    int limit = 10,
  }) {
    return remoteDataSource.getFinancialReport(
      startDate: startDate,
      endDate: endDate,
      outletId: outletId,
      page: page,
      limit: limit,
    );
  }
}
