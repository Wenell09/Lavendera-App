class DashboardSummaryEntity {
  final num totalSales;
  final num totalPaymentsReceived;
  final int totalOrders;
  final int activeOrders;

  const DashboardSummaryEntity({
    required this.totalSales,
    required this.totalPaymentsReceived,
    required this.totalOrders,
    required this.activeOrders,
  });
}

class DashboardOrderStatusEntity {
  final String status;
  final int count;

  const DashboardOrderStatusEntity({required this.status, required this.count});
}

class DashboardPaymentMethodEntity {
  final String method;
  final num total;
  final int count;

  const DashboardPaymentMethodEntity({
    required this.method,
    required this.total,
    required this.count,
  });
}

class DashboardSalesChartEntity {
  final String date;
  final num totalSales;
  final num totalPaymentsReceived;

  const DashboardSalesChartEntity({
    required this.date,
    required this.totalSales,
    required this.totalPaymentsReceived,
  });
}

class DashboardEntity {
  final DashboardSummaryEntity summary;
  final List<DashboardOrderStatusEntity> orderStatus;
  final List<DashboardPaymentMethodEntity> paymentMethods;
  final List<DashboardSalesChartEntity> salesChart;

  const DashboardEntity({
    required this.summary,
    required this.orderStatus,
    required this.paymentMethods,
    required this.salesChart,
  });
}
