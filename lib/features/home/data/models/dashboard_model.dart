import '../../domain/entities/dashboard_entity.dart';

class DashboardSummaryModel extends DashboardSummaryEntity {
  const DashboardSummaryModel({
    required super.totalSales,
    required super.totalPaymentsReceived,
    required super.totalOrders,
    required super.activeOrders,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      totalSales: _parseNum(json['total_sales']),
      totalPaymentsReceived: _parseNum(json['total_payments_received']),
      totalOrders: _parseInt(json['total_orders']),
      activeOrders: _parseInt(json['active_orders']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'total_payments_received': totalPaymentsReceived,
      'total_orders': totalOrders,
      'active_orders': activeOrders,
    };
  }
}

class DashboardOrderStatusModel extends DashboardOrderStatusEntity {
  const DashboardOrderStatusModel({
    required super.status,
    required super.count,
  });

  factory DashboardOrderStatusModel.fromJson(Map<String, dynamic> json) {
    return DashboardOrderStatusModel(
      status: json['status']?.toString() ?? '',
      count: _parseInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'count': count};
  }
}

class DashboardPaymentMethodModel extends DashboardPaymentMethodEntity {
  const DashboardPaymentMethodModel({
    required super.method,
    required super.total,
    required super.count,
  });

  factory DashboardPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return DashboardPaymentMethodModel(
      method: json['method']?.toString() ?? '',
      total: _parseNum(json['total']),
      count: _parseInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'method': method, 'total': total, 'count': count};
  }
}

class DashboardSalesChartModel extends DashboardSalesChartEntity {
  const DashboardSalesChartModel({
    required super.date,
    required super.totalSales,
    required super.totalPaymentsReceived,
  });

  factory DashboardSalesChartModel.fromJson(Map<String, dynamic> json) {
    return DashboardSalesChartModel(
      date: json['date']?.toString() ?? '',
      totalSales: _parseNum(json['total_sales']),
      totalPaymentsReceived: _parseNum(json['total_payments_received']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_sales': totalSales,
      'total_payments_received': totalPaymentsReceived,
    };
  }
}

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.summary,
    required super.orderStatus,
    required super.paymentMethods,
    required super.salesChart,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : <String, dynamic>{};

    final orderStatusList = json['order_status'] is List
        ? (json['order_status'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => DashboardOrderStatusModel.fromJson(item))
              .toList()
        : <DashboardOrderStatusModel>[];

    final paymentMethodsList = json['payment_methods'] is List
        ? (json['payment_methods'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => DashboardPaymentMethodModel.fromJson(item))
              .toList()
        : <DashboardPaymentMethodModel>[];

    final salesChartList = json['sales_chart'] is List
        ? (json['sales_chart'] as List)
              .whereType<Map<String, dynamic>>()
              .map((item) => DashboardSalesChartModel.fromJson(item))
              .toList()
        : <DashboardSalesChartModel>[];

    return DashboardModel(
      summary: DashboardSummaryModel.fromJson(summaryJson),
      orderStatus: orderStatusList,
      paymentMethods: paymentMethodsList,
      salesChart: salesChartList,
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
