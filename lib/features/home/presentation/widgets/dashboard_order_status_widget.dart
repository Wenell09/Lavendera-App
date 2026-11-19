import 'package:flutter/material.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';

import '../../domain/entities/dashboard_entity.dart';

class DashboardOrderStatusWidget extends StatelessWidget {
  final List<DashboardOrderStatusEntity> orderStatuses;

  const DashboardOrderStatusWidget({super.key, required this.orderStatuses});

  static const List<Map<String, dynamic>> _statusConfigs = [
    {
      'key': 'MENUNGGU_KONFIRMASI',
      'label': 'Menunggu Konfirmasi',
      'icon': Icons.hourglass_top_rounded,
      'color': Color(0xFFF59E0B),
      'bgColor': Color(0xFFFFFBEB),
    },
    {
      'key': 'DIPROSES',
      'label': 'Diproses',
      'icon': Icons.local_laundry_service_outlined,
      'color': Color(0xFF3B82F6),
      'bgColor': Color(0xFFEFF6FF),
    },
    {
      'key': 'SELESAI',
      'label': 'Selesai',
      'icon': Icons.check_circle_outline_rounded,
      'color': Color(0xFF10B981),
      'bgColor': Color(0xFFECFDF5),
    },
    {
      'key': 'DIAMBIL',
      'label': 'Diambil',
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFF6366F1),
      'bgColor': Color(0xFFEEF2FF),
    },
    {
      'key': 'DIBATALKAN',
      'label': 'Dibatalkan',
      'icon': Icons.cancel_outlined,
      'color': Color(0xFFEF4444),
      'bgColor': Color(0xFFFEF2F2),
    },
  ];

  int _getCountForStatus(String statusKey) {
    for (final item in orderStatuses) {
      if (item.status.toUpperCase() == statusKey.toUpperCase()) {
        return item.count;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? colorScheme.outlineVariant.withValues(alpha: 0.2)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
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
                'Status Pesanan',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Icon(
                Icons.alt_route_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Status Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;
              final childAspectRatio = constraints.maxWidth > 500 ? 1.8 : 1.6;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _statusConfigs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final cfg = _statusConfigs[index];
                  final key = cfg['key'] as String;
                  final label = cfg['label'] as String;
                  final icon = cfg['icon'] as IconData;
                  final color = cfg['color'] as Color;
                  final bgColor = cfg['bgColor'] as Color;
                  final count = _getCountForStatus(key);

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? color.withValues(alpha: 0.15)
                          : bgColor.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? color.withValues(alpha: 0.3)
                            : color.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colorScheme.surfaceContainerHigh
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.02,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(icon, color: color, size: 18),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: count > 0
                                    ? color
                                    : (isDark
                                        ? colorScheme.surfaceContainerHighest
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                count.toString(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: count > 0
                                      ? Colors.white
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 12,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
