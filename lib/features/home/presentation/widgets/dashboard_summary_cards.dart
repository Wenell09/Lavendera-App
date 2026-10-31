import 'package:flutter/material.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';

import '../../domain/entities/dashboard_entity.dart';

class DashboardSummaryCards extends StatelessWidget {
  final DashboardSummaryEntity summary;

  const DashboardSummaryCards({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top 2 cards: Financial Overview (Penjualan & Pembayaran)
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                title: 'Total Penjualan',
                amount: summary.totalSales,
                subtitle: 'Omset bruto periode ini',
                icon: Icons.trending_up_rounded,
                accentColor: const Color(0xFF4A99AD),
                badgeColor: const Color(0xFFE6F4F7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                title: 'Pembayaran Diterima',
                amount: summary.totalPaymentsReceived,
                subtitle: 'Kas diterima',
                icon: Icons.payments_rounded,
                accentColor: const Color(0xFF10B981),
                badgeColor: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom 2 cards: Operational Overview (Total Pesanan & Pesanan Aktif)
        Row(
          children: [
            Expanded(
              child: _buildOperationalCard(
                title: 'Total Pesanan',
                count: summary.totalOrders,
                unit: 'Pesanan',
                icon: Icons.receipt_long_rounded,
                accentColor: const Color(0xFFF59E0B),
                badgeColor: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOperationalCard(
                title: 'Pesanan Aktif',
                count: summary.activeOrders,
                unit: 'Sedang Proses',
                icon: Icons.local_laundry_service_rounded,
                accentColor: const Color(0xFF6366F1),
                badgeColor: const Color(0xFFEEF2FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialCard({
    required String title,
    required num amount,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(amount),
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.grey.shade400,
              fontSize: 10.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalCard({
    required String title,
    required int count,
    required String unit,
    required IconData icon,
    required Color accentColor,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                count.toString(),
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  unit,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
