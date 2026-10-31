abstract class DashboardEvent {}

class GetDashboardRequest extends DashboardEvent {
  final String? startDate;
  final String? endDate;
  final String? outletId;
  final bool isRefresh;

  GetDashboardRequest({
    this.startDate,
    this.endDate,
    this.outletId,
    this.isRefresh = false,
  });
}
