import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';
import 'package:lavendera/features/home/presentation/presentation/widgets/dashboard_filter_sheet.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/user_outlet/user_outlet_bloc.dart';
import 'package:lavendera/features/profile/domain/entities/profile.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';

import '../../domain/entities/financial_report_entity.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedOutletId;
  String? _staffOutletName;
  List<Outlet> _adminOutlets = [];
  bool _hasInitialFetched = false;
  final ScrollController _scrollController = ScrollController();

  static const Color primaryColor = Color(0xFF4A99AD);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final reportBloc = context.read<ReportBloc>();
      final state = reportBloc.state;
      if (state is ReportLoaded && state.hasMorePages && !state.isLoadingMore) {
        reportBloc.add(
          GetFinancialReportRequest(
            startDate: _formatDateParam(_startDate),
            endDate: _formatDateParam(_endDate),
            outletId: _selectedOutletId,
            loadMore: true,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _initializeData() {
    final profileBloc = context.read<ProfileDetailBloc>();
    if (profileBloc.state is ProfileDetailLoaded) {
      final profile = (profileBloc.state as ProfileDetailLoaded).profile;
      _onProfileAvailable(profile);
    } else {
      profileBloc.add(GetProfileRequest());
    }

    final reportBloc = context.read<ReportBloc>();
    if (reportBloc.state is! ReportLoaded && !_hasInitialFetched) {
      _fetchReport();
    }
  }

  void _onProfileAvailable(Profile profile) {
    if (profile.role.toUpperCase() == 'ADMIN') {
      final outletBloc = context.read<OutletBloc>();
      if (outletBloc.state is! OutletLoaded) {
        outletBloc.add(GetOutletsRequest(limit: 100));
      }
    } else {
      final userOutletBloc = context.read<UserOutletBloc>();
      if (userOutletBloc.state is! UserOutletLoaded) {
        userOutletBloc.add(GetUserOutletRequest(userId: profile.id));
      }
    }
  }

  String _formatDateParam(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _fetchReport({bool isRefresh = false}) {
    _hasInitialFetched = true;
    context.read<ReportBloc>().add(
      GetFinancialReportRequest(
        startDate: _formatDateParam(_startDate),
        endDate: _formatDateParam(_endDate),
        outletId: _selectedOutletId,
        page: 1,
        isRefresh: isRefresh,
      ),
    );
  }

  void _onFilterTap() {
    DashboardFilterSheet.show(
      context: context,
      currentStartDate: _startDate,
      currentEndDate: _endDate,
      onRangeSelected: (range) {
        setState(() {
          _startDate = range.start;
          _endDate = range.end;
        });
        _fetchReport();
      },
    );
  }

  void _onOutletChanged(String? newOutletId) {
    if (_selectedOutletId != newOutletId) {
      setState(() {
        _selectedOutletId = newOutletId;
      });
      _fetchReport();
    }
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

  String _formatDateTime(DateTime dt) {
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
    final day = dt.day;
    final month = monthNames[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute WIB';
  }

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
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileDetailBloc, ProfileDetailState>(
          listener: (context, state) {
            if (state is ProfileDetailLoaded) {
              _onProfileAvailable(state.profile);
            }
          },
        ),
        BlocListener<OutletBloc, OutletState>(
          listener: (context, state) {
            if (state is OutletLoaded) {
              setState(() {
                _adminOutlets = state.outlets.where((o) => o.isActive).toList();
              });
            }
          },
        ),
        BlocListener<UserOutletBloc, UserOutletState>(
          listener: (context, state) {
            if (state is UserOutletLoaded) {
              final outlet = state.userOutlet.outlet;
              final wasNull = _selectedOutletId == null;
              setState(() {
                _selectedOutletId = outlet.id;
                _staffOutletName = outlet.name;
              });
              if (wasNull) {
                _fetchReport();
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Laporan Keuangan',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileDetailBloc, ProfileDetailState>(
            builder: (context, profileState) {
              final profile = profileState is ProfileDetailLoaded
                  ? profileState.profile
                  : null;
              final isAdmin = (profile?.role.toUpperCase() ?? '') == 'ADMIN';

              return Column(
                children: [
                  // Top Filter Bar (Outlet & Date)
                  _buildFilterBar(isAdmin),

                  // Report Body Content
                  Expanded(
                    child: BlocBuilder<ReportBloc, ReportState>(
                      builder: (context, state) {
                        if (state is ReportLoading) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: primaryColor),
                                SizedBox(height: 14),
                                Text(
                                  'Memuat laporan keuangan...',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is ReportError) {
                          if (state.lastReport != null) {
                            return _buildReportContent(
                              report: state.lastReport!,
                              payments:
                                  state.lastPayments ??
                                  state.lastReport!.payments,
                              hasMorePages: false,
                              isLoadingMore: false,
                              errorMessage: state.message,
                            );
                          }
                          return _buildErrorState(state.message);
                        }

                        if (state is ReportLoaded) {
                          return _buildReportContent(
                            report: state.report,
                            payments: state.payments,
                            hasMorePages: state.hasMorePages,
                            isLoadingMore: state.isLoadingMore,
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Outlet Selector / Badge
          Expanded(
            child: isAdmin
                ? _buildAdminOutletSelector()
                : _buildStaffOutletBadge(),
          ),
          const SizedBox(width: 10),
          // Date Filter Button
          InkWell(
            onTap: _onFilterTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      _formatRangeLabel(_startDate, _endDate),
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
    );
  }

  Widget _buildAdminOutletSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedOutletId,
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
            ..._adminOutlets.map((o) {
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
          onChanged: _onOutletChanged,
        ),
      ),
    );
  }

  Widget _buildStaffOutletBadge() {
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
              _staffOutletName ?? 'Outlet Saya',
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Laporan',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _fetchReport(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent({
    required FinancialReportEntity report,
    required List<FinancialReportPaymentEntity> payments,
    required bool hasMorePages,
    required bool isLoadingMore,
    String? errorMessage,
  }) {
    final summary = report.summary;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        _fetchReport(isRefresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: 4 + payments.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 0: Optional Error Notification Banner
          if (index == 0) {
            if (errorMessage != null) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _fetchReport(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }

          // 1: Financial Summary Cards Grid
          if (index == 1) {
            return _buildSummaryCards(summary);
          }

          // 2: Spacing & Section Title
          if (index == 2) {
            return Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Transaksi Pembayaran',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${report.pagination?.total ?? payments.length} Transaksi',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 3: Empty State (if no payments)
          if (index == 3) {
            if (payments.isEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada transaksi pembayaran',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tidak ada riwayat pembayaran terverifikasi pada periode ini.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }

          // Payments List Items
          final paymentIndex = index - 4;
          if (paymentIndex < payments.length) {
            final payment = payments[paymentIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildPaymentCard(payment),
            );
          }

          // Bottom Loading Spinner for pagination
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: primaryColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(FinancialReportSummaryEntity summary) {
    return Column(
      children: [
        // Row 1: Penjualan & Pembayaran
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                title: 'Total Penjualan',
                value: CurrencyFormatter.format(summary.totalSales),
                subtitle: 'Omset bruto',
                icon: Icons.trending_up_rounded,
                accentColor: const Color(0xFF4A99AD),
                bgColor: const Color(0xFFE6F4F7),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryItem(
                title: 'Pembayaran Diterima',
                value: CurrencyFormatter.format(summary.totalPaymentsReceived),
                subtitle: 'Kas terverifikasi',
                icon: Icons.payments_rounded,
                accentColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2: Diskon & Pesanan
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                title: 'Total Diskon',
                value: CurrencyFormatter.format(summary.totalDiscount),
                subtitle: 'Potongan harga',
                icon: Icons.percent_rounded,
                accentColor: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSummaryItem(
                title: 'Total Pesanan',
                value: '${summary.totalOrders} Pesanan',
                subtitle: 'Jumlah order',
                icon: Icons.receipt_long_rounded,
                accentColor: const Color(0xFF6366F1),
                bgColor: const Color(0xFFEEF2FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16.5,
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
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(FinancialReportPaymentEntity payment) {
    final methodLabel = _getMethodLabel(payment.paymentMethod);
    final methodIcon = _getMethodIcon(payment.paymentMethod);
    final isVerified = payment.status.toLowerCase() == 'verified';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Number & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      payment.orderNumber.isNotEmpty
                          ? payment.orderNumber
                          : 'Order',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 12,
                      color: isVerified
                          ? const Color(0xFF059669)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'Terverifikasi' : payment.status,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isVerified
                            ? const Color(0xFF059669)
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Customer Name & Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.customerName.isNotEmpty
                          ? payment.customerName
                          : 'Pelanggan Umum',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (payment.outletName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              payment.outletName,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(payment.amount),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF059669),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Divider(height: 18),

          // Payment Method & Paid Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(methodIcon, size: 15, color: primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    methodLabel,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                _formatDateTime(payment.paidAt),
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
