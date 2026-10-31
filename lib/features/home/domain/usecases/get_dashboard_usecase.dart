import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUsecase {
  final DashboardRepository repository;

  GetDashboardUsecase(this.repository);

  Future<DashboardEntity> call({
    String? startDate,
    String? endDate,
    String? outletId,
  }) {
    return repository.getDashboard(
      startDate: startDate,
      endDate: endDate,
      outletId: outletId,
    );
  }
}
