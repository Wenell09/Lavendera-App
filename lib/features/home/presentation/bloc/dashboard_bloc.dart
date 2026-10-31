import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';

import '../../domain/entities/dashboard_entity.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardUsecase getDashboardUsecase;

  DashboardBloc({required this.getDashboardUsecase})
    : super(DashboardInitial()) {
    on<GetDashboardRequest>((event, emit) async {
      final now = DateTime.now();
      final defaultStart = DateTime(now.year, now.month, 1);
      final defaultEnd = DateTime(now.year, now.month + 1, 0);

      final startDate =
          event.startDate ??
          '${defaultStart.year.toString().padLeft(4, '0')}-${defaultStart.month.toString().padLeft(2, '0')}-${defaultStart.day.toString().padLeft(2, '0')}';
      final endDate =
          event.endDate ??
          '${defaultEnd.year.toString().padLeft(4, '0')}-${defaultEnd.month.toString().padLeft(2, '0')}-${defaultEnd.day.toString().padLeft(2, '0')}';

      DashboardEntity? lastDashboard;
      if (state is DashboardLoaded) {
        lastDashboard = (state as DashboardLoaded).dashboard;
        if (event.isRefresh) {
          emit((state as DashboardLoaded).copyWith(isRefreshing: true));
        } else {
          emit(DashboardLoading());
        }
      } else {
        emit(DashboardLoading());
      }

      try {
        final result = await getDashboardUsecase.call(
          startDate: startDate,
          endDate: endDate,
          outletId: event.outletId,
        );
        emit(
          DashboardLoaded(
            dashboard: result,
            startDate: startDate,
            endDate: endDate,
            outletId: event.outletId,
          ),
        );
      } on ApiException catch (e) {
        emit(
          DashboardError(
            message: e.message.isNotEmpty
                ? e.message
                : 'Gagal memuat data dashboard',
            lastDashboard: lastDashboard,
            startDate: startDate,
            endDate: endDate,
            outletId: event.outletId,
          ),
        );
      } catch (e) {
        emit(
          DashboardError(
            message: 'Gagal memuat data dashboard. Terjadi kesalahan.',
            lastDashboard: lastDashboard,
            startDate: startDate,
            endDate: endDate,
            outletId: event.outletId,
          ),
        );
      }
    });
  }
}
