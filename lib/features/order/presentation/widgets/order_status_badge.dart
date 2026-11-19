import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool isPayment;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isPayment) {
      return _buildPaymentBadge(isDark);
    }
    return _buildOrderStatusBadge(isDark);
  }

  Widget _buildOrderStatusBadge(bool isDark) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'MENUNGGU_KONFIRMASI':
        text = isDark ? Colors.amber.shade300 : const Color(0xFFD97706);
        bg = isDark ? Colors.amber.withValues(alpha: 0.2) : const Color(0xFFFEF3C7);
        label = 'Menunggu';
        icon = Icons.hourglass_top_rounded;
        break;
      case 'DIPROSES':
        text = isDark ? Colors.lightBlue.shade300 : const Color(0xFF0284C7);
        bg = isDark ? Colors.lightBlue.withValues(alpha: 0.2) : const Color(0xFFE0F2FE);
        label = 'Diproses';
        icon = Icons.sync_rounded;
        break;
      case 'SELESAI':
        text = isDark ? Colors.indigo.shade300 : const Color(0xFF4F46E5);
        bg = isDark ? Colors.indigo.withValues(alpha: 0.2) : const Color(0xFFEEF2FF);
        label = 'Selesai';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'DIAMBIL':
        text = isDark ? Colors.green.shade300 : const Color(0xFF16A34A);
        bg = isDark ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFDCFCE7);
        label = 'Diambil';
        icon = Icons.done_all_rounded;
        break;
      case 'DIBATALKAN':
        text = isDark ? Colors.red.shade300 : const Color(0xFFDC2626);
        bg = isDark ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFFEE2E2);
        label = 'Dibatalkan';
        icon = Icons.cancel_outlined;
        break;
      default:
        text = isDark ? Colors.grey.shade300 : Colors.grey.shade700;
        bg = isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.shade100;
        label = status;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(bool isDark) {
    Color bg;
    Color text;
    String label;
    IconData icon;
    switch (status.toUpperCase()) {
      case 'PAID':
        text = isDark ? Colors.green.shade300 : const Color(0xFF16A34A);
        bg = isDark ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFDCFCE7);
        label = 'Lunas';
        icon = Icons.check_circle_rounded;
        break;
      case 'PENDING':
        text = isDark ? Colors.amber.shade300 : const Color(0xFFD97706);
        bg = isDark ? Colors.amber.withValues(alpha: 0.2) : const Color(0xFFFEF3C7);
        label = 'Pending';
        icon = Icons.schedule_rounded;
        break;
      case 'UNPAID':
      default:
        text = isDark ? Colors.red.shade300 : const Color(0xFFDC2626);
        bg = isDark ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFFEE2E2);
        label = 'Belum Bayar';
        icon = Icons.error_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
