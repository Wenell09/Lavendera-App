import 'package:flutter/material.dart';

class OrderTimelineWidget extends StatelessWidget {
  final String currentStatus;

  const OrderTimelineWidget({super.key, required this.currentStatus});

  static const List<Map<String, dynamic>> _steps = [
    {
      'status': 'MENUNGGU_KONFIRMASI',
      'label': 'Menunggu',
      'icon': Icons.hourglass_top_rounded,
    },
    {
      'status': 'DIPROSES',
      'label': 'Diproses',
      'icon': Icons.sync_rounded,
    },
    {
      'status': 'SELESAI',
      'label': 'Selesai',
      'icon': Icons.check_circle_outline_rounded,
    },
    {
      'status': 'DIAMBIL',
      'label': 'Diambil',
      'icon': Icons.done_all_rounded,
    },
  ];

  int _getStepIndex(String status) {
    switch (status.toUpperCase()) {
      case 'MENUNGGU_KONFIRMASI':
        return 0;
      case 'DIPROSES':
        return 1;
      case 'SELESAI':
        return 2;
      case 'DIAMBIL':
        return 3;
      default:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isCanceled = currentStatus.toUpperCase() == 'DIBATALKAN';

    if (isCanceled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_rounded, color: colorScheme.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesanan Dibatalkan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pesanan ini telah dibatalkan dan tidak lagi diproses.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: colorScheme.error.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _getStepIndex(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withValues(alpha: 0.2)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Alur Status Pesanan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Row(
            children: List.generate(_steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Divider line
                final stepBefore = index ~/ 2;
                final isPassed = currentIndex > stepBefore;
                return Expanded(
                  child: Container(
                    height: 2.5,
                    color: isPassed
                        ? colorScheme.primary
                        : (isDark
                            ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                            : const Color(0xFFCBD5E1)),
                  ),
                );
              }

              // Step bubble
              final stepIndex = index ~/ 2;
              final step = _steps[stepIndex];
              final isCompleted = currentIndex >= stepIndex;
              final isCurrent = currentIndex == stepIndex;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? colorScheme.primary
                          : isCompleted
                              ? colorScheme.primary.withValues(alpha: 0.15)
                              : (isDark
                                  ? colorScheme.surfaceContainerHighest
                                  : Colors.white),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? colorScheme.primary
                            : (isDark
                                ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                                : const Color(0xFFCBD5E1)),
                        width: isCurrent ? 2.5 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        step['icon'] as IconData,
                        size: 15,
                        color: isCurrent
                            ? colorScheme.onPrimary
                            : isCompleted
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent
                          ? colorScheme.onSurface
                          : isCompleted
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
