import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardEntity> getDashboard({
    String? startDate,
    String? endDate,
    String? outletId,
  }) {
    return remoteDataSource.getDashboard(
      startDate: startDate,
      endDate: endDate,
      outletId: outletId,
    );
  }
}
