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
    if (isPayment) {
      return _buildPaymentBadge();
    }
    return _buildOrderStatusBadge();
  }

  Widget _buildOrderStatusBadge() {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'MENUNGGU_KONFIRMASI':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = 'Menunggu';
        icon = Icons.hourglass_top_rounded;
        break;
      case 'DIPROSES':
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0284C7);
        label = 'Diproses';
        icon = Icons.sync_rounded;
        break;
      case 'SELESAI':
        bg = const Color(0xFFEEF2FF);
        text = const Color(0xFF4F46E5);
        label = 'Selesai';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'DIAMBIL':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
        label = 'Diambil';
        icon = Icons.done_all_rounded;
        break;
      case 'DIBATALKAN':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        label = 'Dibatalkan';
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
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

  Widget _buildPaymentBadge() {
    Color bg;
    Color text;
    String label;
    IconData icon;
    switch (status.toUpperCase()) {
      case 'PAID':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
        label = 'Lunas';
        icon = Icons.check_circle_rounded;
        break;
      case 'PENDING':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = 'Pending';
        icon = Icons.schedule_rounded;
        break;
      case 'UNPAID':
      default:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
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
