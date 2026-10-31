import '../../domain/entities/financial_report_entity.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final FinancialReportEntity report;
  final List<FinancialReportPaymentEntity> payments;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMorePages;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String startDate;
  final String endDate;
  final String? outletId;

  ReportLoaded({
    required this.report,
    required this.payments,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasMorePages,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    required this.startDate,
    required this.endDate,
    this.outletId,
  });

  ReportLoaded copyWith({
    FinancialReportEntity? report,
    List<FinancialReportPaymentEntity>? payments,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMorePages,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? startDate,
    String? endDate,
    String? outletId,
  }) {
    return ReportLoaded(
      report: report ?? this.report,
      payments: payments ?? this.payments,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      outletId: outletId ?? this.outletId,
    );
  }
}

class ReportError extends ReportState {
  final String message;
  final FinancialReportEntity? lastReport;
  final List<FinancialReportPaymentEntity>? lastPayments;
  final String? startDate;
  final String? endDate;
  final String? outletId;

  ReportError({
    required this.message,
    this.lastReport,
    this.lastPayments,
    this.startDate,
    this.endDate,
    this.outletId,
  });
}
