import 'package:flutter/material.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/profile/domain/entities/profile.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final Profile? profile;
  final List<Outlet> outlets;
  final String? selectedOutletId;
  final String? staffOutletName;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<String?> onOutletChanged;
  final VoidCallback onFilterTap;

  const DashboardHeaderWidget({
    super.key,
    required this.profile,
    required this.outlets,
    required this.selectedOutletId,
    required this.staffOutletName,
    required this.startDate,
    required this.endDate,
    required this.onOutletChanged,
    required this.onFilterTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _formatRangeLabel(DateTime start, DateTime end) {
    const monthNames = [
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

    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${start.day} ${monthNames[start.month - 1]} ${start.year}';
    }

    if (start.year == end.year && start.month == end.month) {
      return '${start.day} - ${end.day} ${monthNames[start.month - 1]} ${start.year}';
    }

    if (start.year == end.year) {
      return '${start.day} ${monthNames[start.month - 1]} - ${end.day} ${monthNames[end.month - 1]} ${start.year}';
    }

    return '${start.day} ${monthNames[start.month - 1]} ${start.year} - ${end.day} ${monthNames[end.month - 1]} ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4A99AD);
    final userName = profile?.name.isNotEmpty == true
        ? profile!.name
        : 'Pengguna';
    final role = (profile?.role.isNotEmpty == true ? profile!.role : 'STAFF')
        .toUpperCase();
    final isAdmin = role == 'ADMIN';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Profile Name & Role Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdmin
                          ? Icons.admin_panel_settings_rounded
                          : Icons.badge_rounded,
                      size: 14,
                      color: isAdmin ? const Color(0xFF059669) : primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      role,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAdmin ? const Color(0xFF059669) : primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Outlet & Date Filter Row
          Row(
            children: [
              // Outlet Selector / Badge
              Expanded(
                child: isAdmin
                    ? _buildAdminOutletSelector(context)
                    : _buildStaffOutletBadge(),
              ),
              const SizedBox(width: 10),
              // Date Range Filter Button
              InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(
                          _formatRangeLabel(startDate, endDate),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOutletSelector(BuildContext context) {
    const primaryColor = Color(0xFF4A99AD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedOutletId,
          isExpanded: true,
          icon: Icon(
            Icons.unfold_more_rounded,
            size: 18,
            color: Colors.grey.shade600,
          ),
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  const Icon(
                    Icons.store_mall_directory_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Semua Outlet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ...outlets.map((o) {
              return DropdownMenuItem<String?>(
                value: o.id,
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        o.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onOutletChanged,
        ),
      ),
    );
  }

  Widget _buildStaffOutletBadge() {
    const primaryColor = Color(0xFF4A99AD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_rounded, size: 16, color: primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              staffOutletName ?? 'Outlet Saya',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
