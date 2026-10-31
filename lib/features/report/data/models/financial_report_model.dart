import 'package:lavendera/core/models/pagination_model.dart';

import '../../domain/entities/financial_report_entity.dart';

class FinancialReportSummaryModel extends FinancialReportSummaryEntity {
  const FinancialReportSummaryModel({
    required super.totalSales,
    required super.totalDiscount,
    required super.totalPaymentsReceived,
    required super.totalOrders,
  });

  factory FinancialReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportSummaryModel(
      totalSales: _parseNum(json['total_sales']),
      totalDiscount: _parseNum(json['total_discount']),
      totalPaymentsReceived: _parseNum(json['total_payments_received']),
      totalOrders: _parseInt(json['total_orders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'total_discount': totalDiscount,
      'total_payments_received': totalPaymentsReceived,
      'total_orders': totalOrders,
    };
  }
}

class FinancialReportPaymentModel extends FinancialReportPaymentEntity {
  const FinancialReportPaymentModel({
    required super.paymentId,
    required super.orderId,
    required super.orderNumber,
    required super.customerName,
    required super.outletName,
    required super.paymentMethod,
    required super.amount,
    required super.status,
    required super.paidAt,
  });

  factory FinancialReportPaymentModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportPaymentModel(
      paymentId: json['payment_id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      orderNumber: json['order_number']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      outletName: json['outlet_name']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      amount: _parseNum(json['amount']),
      status: json['status']?.toString() ?? '',
      paidAt: _parseDateTime(json['paid_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'order_number': orderNumber,
      'customer_name': customerName,
      'outlet_name': outletName,
      'payment_method': paymentMethod,
      'amount': amount,
      'status': status,
      'paid_at': paidAt.toIso8601String(),
    };
  }
}

class FinancialReportModel extends FinancialReportEntity {
  const FinancialReportModel({
    required super.summary,
    required super.payments,
    super.pagination,
  });

  factory FinancialReportModel.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? metaJson,
  ) {
    final summaryJson = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};

    final paymentsList = json['payments'] is List
        ? (json['payments'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => FinancialReportPaymentModel.fromJson(item))
              .toList()
        : <FinancialReportPaymentModel>[];

    Pagination? pagination;
    if (metaJson != null && metaJson['pagination'] is Map<String, dynamic>) {
      pagination = Pagination.fromJson(
        metaJson['pagination'] as Map<String, dynamic>,
      );
    }

    return FinancialReportModel(
      summary: FinancialReportSummaryModel.fromJson(summaryJson),
      payments: paymentsList,
      pagination: pagination,
    );
  }
}

num _parseNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

DateTime _parseDateTime(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString())?.toLocal() ?? DateTime.now();
}
