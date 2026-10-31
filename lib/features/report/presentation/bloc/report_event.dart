abstract class ReportEvent {}

class GetFinancialReportRequest extends ReportEvent {
  final String? startDate;
  final String? endDate;
  final String? outletId;
  final int page;
  final int limit;
  final bool isRefresh;
  final bool loadMore;

  GetFinancialReportRequest({
    this.startDate,
    this.endDate,
    this.outletId,
    this.page = 1,
    this.limit = 10,
    this.isRefresh = false,
    this.loadMore = false,
  });
}
