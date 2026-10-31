import 'package:lavendera/core/models/pagination_model.dart';

class FinancialReportSummaryEntity {
  final num totalSales;
  final num totalDiscount;
  final num totalPaymentsReceived;
  final int totalOrders;

  const FinancialReportSummaryEntity({
    required this.totalSales,
    required this.totalDiscount,
    required this.totalPaymentsReceived,
    required this.totalOrders,
  });
}

class FinancialReportPaymentEntity {
  final String paymentId;
  final String orderId;
  final String orderNumber;
  final String customerName;
  final String outletName;
  final String paymentMethod;
  final num amount;
  final String status;
  final DateTime paidAt;

  const FinancialReportPaymentEntity({
    required this.paymentId,
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.outletName,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    required this.paidAt,
  });
}

class FinancialReportEntity {
  final FinancialReportSummaryEntity summary;
  final List<FinancialReportPaymentEntity> payments;
  final Pagination? pagination;

  const FinancialReportEntity({
    required this.summary,
    required this.payments,
    this.pagination,
  });
}
