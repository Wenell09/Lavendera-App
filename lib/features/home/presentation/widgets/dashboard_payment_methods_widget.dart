import 'package:flutter/material.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';

import '../../domain/entities/dashboard_entity.dart';

class DashboardPaymentMethodsWidget extends StatelessWidget {
  final List<DashboardPaymentMethodEntity> paymentMethods;

  const DashboardPaymentMethodsWidget({
    super.key,
    required this.paymentMethods,
  });

  String _getMethodLabel(String method) {
    final lower = method.toLowerCase().trim();
    switch (lower) {
      case 'cash':
        return 'Tunai';
      case 'qris':
        return 'QRIS';
      case 'transfer':
      case 'bank_transfer':
        return 'Transfer Bank';
      case 'debit':
      case 'debit_card':
        return 'Kartu Debit';
      case 'credit':
      case 'credit_card':
        return 'Kartu Kredit';
      default:
        if (method.isEmpty) return 'Lainnya';
        return method[0].toUpperCase() + method.substring(1);
    }
  }

  IconData _getMethodIcon(String method) {
    final lower = method.toLowerCase().trim();
    switch (lower) {
      case 'cash':
        return Icons.payments_outlined;
      case 'qris':
        return Icons.qr_code_2_rounded;
      case 'transfer':
      case 'bank_transfer':
        return Icons.account_balance_outlined;
      case 'debit':
      case 'debit_card':
      case 'credit':
      case 'credit_card':
        return Icons.credit_card_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = paymentMethods.isEmpty;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metode Pembayaran',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Text(
                'Belum ada transaksi pembayaran pada periode ini',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentMethods.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 16, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final item = paymentMethods[index];
                final label = _getMethodLabel(item.method);
                final icon = _getMethodIcon(item.method);

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A99AD).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFF4A99AD),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${item.count} transaksi',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.total),
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
