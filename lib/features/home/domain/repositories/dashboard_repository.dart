import '../entities/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<DashboardEntity> getDashboard({
    String? startDate,
    String? endDate,
    String? outletId,
  });
}
