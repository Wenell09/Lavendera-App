import 'package:flutter/material.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';

class DashboardFilterSheet extends StatelessWidget {
  final DateTime currentStartDate;
  final DateTime currentEndDate;
  final ValueChanged<DateTimeRange> onRangeSelected;

  const DashboardFilterSheet({
    super.key,
    required this.currentStartDate,
    required this.currentEndDate,
    required this.onRangeSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required DateTime currentStartDate,
    required DateTime currentEndDate,
    required ValueChanged<DateTimeRange> onRangeSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DashboardFilterSheet(
        currentStartDate: currentStartDate,
        currentEndDate: currentEndDate,
        onRangeSelected: onRangeSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4A99AD);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);

    final sevenDaysAgo = today.subtract(const Duration(days: 6));
    final thirtyDaysAgo = today.subtract(const Duration(days: 29));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Filter Periode Laporan',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pilih rentang tanggal untuk memperbarui data dashboard',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              _buildPresetOption(
                context: context,
                title: 'Bulan Ini',
                subtitle:
                    '${_formatDate(thisMonthStart)} - ${_formatDate(thisMonthEnd)}',
                isSelected: _isSameRange(
                  currentStartDate,
                  currentEndDate,
                  thisMonthStart,
                  thisMonthEnd,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onRangeSelected(
                    DateTimeRange(start: thisMonthStart, end: thisMonthEnd),
                  );
                },
              ),
              _buildPresetOption(
                context: context,
                title: 'Hari Ini',
                subtitle: _formatDate(today),
                isSelected: _isSameRange(
                  currentStartDate,
                  currentEndDate,
                  today,
                  today,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onRangeSelected(DateTimeRange(start: today, end: today));
                },
              ),
              _buildPresetOption(
                context: context,
                title: '7 Hari Terakhir',
                subtitle:
                    '${_formatDate(sevenDaysAgo)} - ${_formatDate(today)}',
                isSelected: _isSameRange(
                  currentStartDate,
                  currentEndDate,
                  sevenDaysAgo,
                  today,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onRangeSelected(
                    DateTimeRange(start: sevenDaysAgo, end: today),
                  );
                },
              ),
              _buildPresetOption(
                context: context,
                title: '30 Hari Terakhir',
                subtitle:
                    '${_formatDate(thirtyDaysAgo)} - ${_formatDate(today)}',
                isSelected: _isSameRange(
                  currentStartDate,
                  currentEndDate,
                  thirtyDaysAgo,
                  today,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onRangeSelected(
                    DateTimeRange(start: thirtyDaysAgo, end: today),
                  );
                },
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Pilih Rentang Tanggal Kustom',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                subtitle: Text(
                  'Tentukan tanggal mulai dan selesai secara manual',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: primaryColor,
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(
                      start: currentStartDate,
                      end: currentEndDate,
                    ),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: primaryColor,
                            onPrimary: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    onRangeSelected(picked);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFF4A99AD);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? primaryColor : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade500),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: primaryColor)
          : null,
      onTap: onTap,
    );
  }

  bool _isSameRange(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    return s1.year == s2.year &&
        s1.month == s2.month &&
        s1.day == s2.day &&
        e1.year == e2.year &&
        e1.month == e2.month &&
        e1.day == e2.day;
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
  }
}
