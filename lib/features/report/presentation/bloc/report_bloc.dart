import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';

import '../../domain/entities/financial_report_entity.dart';
import '../../domain/usecases/get_financial_report_usecase.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetFinancialReportUsecase getFinancialReportUsecase;

  ReportBloc({required this.getFinancialReportUsecase})
    : super(ReportInitial()) {
    on<GetFinancialReportRequest>((event, emit) async {
      final now = DateTime.now();
      final defaultStart = DateTime(now.year, now.month, 1);
      final defaultEnd = DateTime(now.year, now.month + 1, 0);

      final startDate =
          event.startDate ??
          '${defaultStart.year.toString().padLeft(4, '0')}-${defaultStart.month.toString().padLeft(2, '0')}-${defaultStart.day.toString().padLeft(2, '0')}';
      final endDate =
          event.endDate ??
          '${defaultEnd.year.toString().padLeft(4, '0')}-${defaultEnd.month.toString().padLeft(2, '0')}-${defaultEnd.day.toString().padLeft(2, '0')}';

      if (event.loadMore) {
        if (state is! ReportLoaded) return;
        final currentState = state as ReportLoaded;
        if (currentState.isLoadingMore || !currentState.hasMorePages) return;

        emit(currentState.copyWith(isLoadingMore: true));

        try {
          final nextPage = currentState.currentPage + 1;
          final result = await getFinancialReportUsecase.call(
            startDate: startDate,
            endDate: endDate,
            outletId: event.outletId,
            page: nextPage,
            limit: event.limit,
          );

          final updatedPayments = List<FinancialReportPaymentEntity>.from(
            currentState.payments,
          )..addAll(result.payments);

          final totalPages = result.pagination?.totalPages ?? 1;
          final totalItems = result.pagination?.total ?? updatedPayments.length;

          emit(
            currentState.copyWith(
              report: result,
              payments: updatedPayments,
              currentPage: nextPage,
              totalPages: totalPages,
              totalItems: totalItems,
              hasMorePages: nextPage < totalPages,
              isLoadingMore: false,
            ),
          );
        } catch (e) {
          emit(currentState.copyWith(isLoadingMore: false));
        }
        return;
      }

      FinancialReportEntity? lastReport;
      List<FinancialReportPaymentEntity>? lastPayments;
      if (state is ReportLoaded) {
        final current = state as ReportLoaded;
        lastReport = current.report;
        lastPayments = current.payments;
        if (event.isRefresh) {
          emit(current.copyWith(isRefreshing: true));
        } else {
          emit(ReportLoading());
        }
      } else {
        emit(ReportLoading());
      }

      try {
        final result = await getFinancialReportUsecase.call(
          startDate: startDate,
          endDate: endDate,
          outletId: event.outletId,
          page: 1,
          limit: event.limit,
        );

        final totalPages = result.pagination?.totalPages ?? 1;
        final totalItems = result.pagination?.total ?? result.payments.length;

        emit(
          ReportLoaded(
            report: result,
            payments: result.payments,
            currentPage: 1,
            totalPages: totalPages,
            totalItems: totalItems,
            hasMorePages: 1 < totalPages,
            startDate: startDate,
            endDate: endDate,
            outletId: event.outletId,
          ),
        );
      } on ApiException catch (e) {
        emit(
          ReportError(
            message: e.message.isNotEmpty
                ? e.message
                : 'Gagal memuat laporan keuangan',
            lastReport: lastReport,
            lastPayments: lastPayments,
            startDate: startDate,
            endDate: endDate,
            outletId: event.outletId,
          ),
        );
      } catch (e) {
        emit(
          ReportError(
            message: 'Gagal memuat laporan keuangan. Terjadi kesalahan.',
            lastReport: lastReport,
            lastPayments: lastPayments,
            startDate: startDate,
            endDate: endDate,
            outletId: event.outletId,
          ),
        );
      }
    });
  }
}
