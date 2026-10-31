import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';

import '../../../domain/entities/dashboard_entity.dart';

class DashboardSalesChart extends StatefulWidget {
  final List<DashboardSalesChartEntity> chartData;

  const DashboardSalesChart({super.key, required this.chartData});

  @override
  State<DashboardSalesChart> createState() => _DashboardSalesChartState();
}

class _DashboardSalesChartState extends State<DashboardSalesChart> {
  int? _selectedIndex;

  static const Color salesColor = Color(0xFF4A99AD);
  static const Color paymentColor = Color(0xFF10B981);

  List<DashboardSalesChartEntity> _getSortedData() {
    final list = List<DashboardSalesChartEntity>.from(widget.chartData);
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  String _formatAxisDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = parts[2];
        final monthInt = int.tryParse(parts[1]) ?? 1;
        const shortMonths = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des',
        ];
        return '$day ${shortMonths[monthInt - 1]}';
      }
    } catch (_) {}
    return dateStr;
  }

  String _formatCompactNumber(num value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000000) {
      final val = value / 1000000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}jt';
    }
    if (value >= 1000) {
      final val = value / 1000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}rb';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final sortedData = _getSortedData();
    final isEmpty = sortedData.isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Legends
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren Penjualan & Pembayaran',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perbandingan omset vs kas diterima per tanggal',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legend Indicators
          Row(
            children: [
              _buildLegendItem('Penjualan', salesColor),
              const SizedBox(width: 16),
              _buildLegendItem('Pembayaran', paymentColor),
            ],
          ),
          const SizedBox(height: 16),

          if (isEmpty)
            _buildEmptyState()
          else ...[
            // Selected Bar Info Banner (Tooltip detail)
            if (_selectedIndex != null &&
                _selectedIndex! < sortedData.length) ...[
              _buildDetailBanner(sortedData[_selectedIndex!]),
              const SizedBox(height: 12),
            ],
            // Bar Chart Visualizer
            _buildChartContent(sortedData),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 150,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'Tidak ada data penjualan pada periode ini',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBanner(DashboardSalesChartEntity item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                _formatAxisDate(item.date),
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Jual: ${CurrencyFormatter.format(item.totalSales)}',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: salesColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bayar: ${CurrencyFormatter.format(item.totalPaymentsReceived)}',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: paymentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartContent(List<DashboardSalesChartEntity> data) {
    num maxVal = 0;
    for (var d in data) {
      maxVal = math.max(
        maxVal,
        math.max(d.totalSales, d.totalPaymentsReceived),
      );
    }
    final bool hasTransactions = maxVal > 0;

    const chartHeight = 160.0;
    const barWidth = 10.0;
    const itemSpacing = 16.0;

    return Column(
      children: [
        // Grid with Y-axis markers & bars
        SizedBox(
          height: chartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Y-axis labels
              SizedBox(
                width: 44,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hasTransactions ? _formatCompactNumber(maxVal) : '0',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 9.5,
                      ),
                    ),
                    Text(
                      hasTransactions ? _formatCompactNumber(maxVal / 2) : '0',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 9.5,
                      ),
                    ),
                    Text(
                      '0',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chart area with horizontal scroll support
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentWidth = math.max(
                      constraints.maxWidth,
                      data.length * (barWidth * 2 + itemSpacing + 8),
                    );

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: data.length > 7,
                      child: SizedBox(
                        width: contentWidth,
                        child: Stack(
                          children: [
                            // Background guideline lines
                            Positioned.fill(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Divider(
                                    height: 1,
                                    thickness: 0.8,
                                    color: Colors.grey.shade100,
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 0.8,
                                    color: Colors.grey.shade100,
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.grey.shade200,
                                  ),
                                ],
                              ),
                            ),
                            if (!hasTransactions)
                              Positioned.fill(
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100.withValues(
                                        alpha: 0.85,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Belum ada transaksi',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // Bars row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(data.length, (idx) {
                                final item = data[idx];
                                final isSelected = _selectedIndex == idx;

                                final salesHeight =
                                    (hasTransactions && item.totalSales > 0)
                                    ? math.max(
                                        (item.totalSales / maxVal) *
                                            (chartHeight - 16),
                                        3.0,
                                      )
                                    : 0.0;
                                final paymentHeight =
                                    (hasTransactions &&
                                        item.totalPaymentsReceived > 0)
                                    ? math.max(
                                        (item.totalPaymentsReceived / maxVal) *
                                            (chartHeight - 16),
                                        3.0,
                                      )
                                    : 0.0;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = _selectedIndex == idx
                                          ? null
                                          : idx;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.grey.shade100
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Sales Bar
                                        Container(
                                          width: barWidth,
                                          height: salesHeight,
                                          decoration: BoxDecoration(
                                            color: salesHeight > 0
                                                ? salesColor
                                                : Colors.transparent,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(3),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        // Payment Bar
                                        Container(
                                          width: barWidth,
                                          height: paymentHeight,
                                          decoration: BoxDecoration(
                                            color: paymentHeight > 0
                                                ? paymentColor
                                                : Colors.transparent,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(3),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // X-axis Dates Row
        Row(
          children: [
            const SizedBox(width: 52), // Space aligned with Y-axis
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = math.max(
                    constraints.maxWidth,
                    data.length * (barWidth * 2 + itemSpacing + 8),
                  );
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: data.length > 7,
                    child: SizedBox(
                      width: contentWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(data.length, (idx) {
                          final item = data[idx];
                          final isSelected = _selectedIndex == idx;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              _formatAxisDate(item.date),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isSelected
                                    ? salesColor
                                    : Colors.grey.shade500,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 9.5,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
