import '../../domain/entities/dashboard_entity.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardEntity dashboard;
  final String startDate;
  final String endDate;
  final String? outletId;
  final bool isRefreshing;

  DashboardLoaded({
    required this.dashboard,
    required this.startDate,
    required this.endDate,
    this.outletId,
    this.isRefreshing = false,
  });

  DashboardLoaded copyWith({
    DashboardEntity? dashboard,
    String? startDate,
    String? endDate,
    String? outletId,
    bool? isRefreshing,
  }) {
    return DashboardLoaded(
      dashboard: dashboard ?? this.dashboard,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      outletId: outletId ?? this.outletId,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  final DashboardEntity? lastDashboard;
  final String? startDate;
  final String? endDate;
  final String? outletId;

  DashboardError({
    required this.message,
    this.lastDashboard,
    this.startDate,
    this.endDate,
    this.outletId,
  });
}
