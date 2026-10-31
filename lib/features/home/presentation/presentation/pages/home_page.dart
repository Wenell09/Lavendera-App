import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/home/domain/entities/dashboard_entity.dart';
import 'package:lavendera/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:lavendera/features/home/presentation/bloc/dashboard_event.dart';
import 'package:lavendera/features/home/presentation/bloc/dashboard_state.dart';
import 'package:lavendera/features/home/presentation/presentation/widgets/dashboard_filter_sheet.dart';
import 'package:lavendera/features/home/presentation/presentation/widgets/dashboard_header_widget.dart';
import 'package:lavendera/features/home/presentation/presentation/widgets/dashboard_order_status_widget.dart';
import 'package:lavendera/features/home/presentation/presentation/widgets/dashboard_payment_methods_widget.dart';
import 'package:lavendera/features/home/presentation/presentation/widgets/dashboard_quick_menu_widget.dart';
import 'package:lavendera/features/home/presentation/presentation/widgets/dashboard_sales_chart.dart';
import 'package:lavendera/features/home/presentation/presentation/widgets/dashboard_summary_cards.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';
import 'package:lavendera/features/outlet_user/presentation/bloc/user_outlet/user_outlet_bloc.dart';
import 'package:lavendera/features/profile/domain/entities/profile.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedOutletId;
  String? _staffOutletName;
  List<Outlet> _adminOutlets = [];
  bool _hasInitialFetched = false;

  static const Color primaryColor = Color(0xFF4A99AD);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final profileBloc = context.read<ProfileDetailBloc>();
    if (profileBloc.state is ProfileDetailLoaded) {
      final profile = (profileBloc.state as ProfileDetailLoaded).profile;
      _onProfileAvailable(profile);
    } else {
      profileBloc.add(GetProfileRequest());
    }

    final dashBloc = context.read<DashboardBloc>();
    if (dashBloc.state is! DashboardLoaded && !_hasInitialFetched) {
      _fetchDashboard();
    }
  }

  void _onProfileAvailable(Profile profile) {
    if (profile.role.toUpperCase() == 'ADMIN') {
      final outletBloc = context.read<OutletBloc>();
      if (outletBloc.state is! OutletLoaded) {
        outletBloc.add(GetOutletsRequest(limit: 100));
      }
    } else {
      // Role is STAFF: retrieve staff's assigned outlet
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

  void _fetchDashboard({bool isRefresh = false}) {
    _hasInitialFetched = true;
    context.read<DashboardBloc>().add(
      GetDashboardRequest(
        startDate: _formatDateParam(_startDate),
        endDate: _formatDateParam(_endDate),
        outletId: _selectedOutletId,
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
        _fetchDashboard();
      },
    );
  }

  void _onOutletChanged(String? newOutletId) {
    if (_selectedOutletId != newOutletId) {
      setState(() {
        _selectedOutletId = newOutletId;
      });
      _fetchDashboard();
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
              // If initial fetch was sent without outlet_id, refresh with staff's outlet
              if (wasNull) {
                _fetchDashboard();
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Lavendera',
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

              return Column(
                children: [
                  DashboardHeaderWidget(
                    profile: profile,
                    outlets: _adminOutlets,
                    selectedOutletId: _selectedOutletId,
                    staffOutletName: _staffOutletName,
                    startDate: _startDate,
                    endDate: _endDate,
                    onOutletChanged: _onOutletChanged,
                    onFilterTap: _onFilterTap,
                  ),
                  Expanded(
                    child: BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, state) {
                        if (state is DashboardLoading) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: primaryColor),
                                SizedBox(height: 14),
                                Text(
                                  'Memuat data dashboard...',
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

                        if (state is DashboardError) {
                          if (state.lastDashboard != null) {
                            return _buildDashboardContent(
                              context: context,
                              profile: profile,
                              dashboard: state.lastDashboard!,
                              errorMessage: state.message,
                            );
                          }
                          return _buildErrorState(state.message);
                        }

                        if (state is DashboardLoaded) {
                          return _buildDashboardContent(
                            context: context,
                            profile: profile,
                            dashboard: state.dashboard,
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
              'Gagal Memuat Dashboard',
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
              onPressed: () => _fetchDashboard(),
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

  Widget _buildDashboardContent({
    required BuildContext context,
    required Profile? profile,
    required DashboardEntity dashboard,
    String? errorMessage,
  }) {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () async {
        _fetchDashboard(isRefresh: true);
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          if (errorMessage != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    onPressed: () => _fetchDashboard(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ],

          // 1. Summary Cards
          DashboardSummaryCards(summary: dashboard.summary),
          const SizedBox(height: 16),

          // 2. Sales Chart
          DashboardSalesChart(chartData: dashboard.salesChart),
          const SizedBox(height: 16),

          // 3. Order Status Summary
          DashboardOrderStatusWidget(orderStatuses: dashboard.orderStatus),
          const SizedBox(height: 16),

          // 4. Payment Methods Summary
          DashboardPaymentMethodsWidget(
            paymentMethods: dashboard.paymentMethods,
          ),
          const SizedBox(height: 16),

          // 5. Existing Operational Quick Menus
          DashboardQuickMenuWidget(profile: profile),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
