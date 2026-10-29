import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';

import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../widgets/order_card_widget.dart';
import 'create_order_page.dart';
import 'order_detail_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, String?>> _statusTabs = [
    {'label': 'Semua', 'value': null},
    {'label': 'Menunggu', 'value': 'MENUNGGU_KONFIRMASI'},
    {'label': 'Diproses', 'value': 'DIPROSES'},
    {'label': 'Selesai', 'value': 'SELESAI'},
    {'label': 'Diambil', 'value': 'DIAMBIL'},
    {'label': 'Dibatalkan', 'value': 'DIBATALKAN'},
  ];

  @override
  void initState() {
    super.initState();
    final bloc = context.read<OrderBloc>();
    if (bloc.state is! OrderLoaded) {
      _loadOrders(page: 1);
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String? _formatDateParam(DateTime? dt) {
    if (dt == null) return null;
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  void _loadOrders({int page = 1}) {
    final query = _searchController.text.trim();
    context.read<OrderBloc>().add(
      GetOrdersRequest(
        search: query.isEmpty ? null : query,
        status: _selectedStatus,
        startDate: _formatDateParam(_startDate),
        endDate: _formatDateParam(_endDate),
        page: page,
      ),
    );
  }

  void _onScroll() {
    if (_isBottom) {
      final bloc = context.read<OrderBloc>();
      final state = bloc.state;
      if (state is OrderLoaded && state.hasMorePages) {
        _loadOrders(page: state.currentPage + 1);
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadOrders(page: 1);
    });
    setState(() {});
  }

  void _onStatusTabSelected(String? status) {
    if (_selectedStatus == status) return;
    setState(() {
      _selectedStatus = status;
    });
    _loadOrders(page: 1);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A99AD),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadOrders(page: 1);
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadOrders(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Pesanan',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _startDate != null
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: _startDate != null
                  ? const Color(0xFF4A99AD)
                  : const Color(0xFF64748B),
            ),
            tooltip: 'Filter Tanggal',
            onPressed: _pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87, size: 20),
            onPressed: () => _loadOrders(page: 1),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Controls (Search & Status Tabs)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari nomor order...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                // Active Date Range Pill (if any)
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A99AD)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Color(0xFF4A99AD),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatDateParam(_startDate)} s/d ${_formatDateParam(_endDate)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A99AD),
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: _clearDateFilter,
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Color(0xFF4A99AD),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Horizontal Status Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _statusTabs.map((tab) {
                      final isSelected = _selectedStatus == tab['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(tab['label']!),
                          selected: isSelected,
                          onSelected: (_) => _onStatusTabSelected(tab['value']),
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                          selectedColor: const Color(0xFF4A99AD),
                          backgroundColor: const Color(0xFFF1F5F9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF4A99AD)
                                  : Colors.transparent,
                            ),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Order List
          Expanded(
            child: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4A99AD)),
                  );
                }

                if (state is OrderError &&
                    (state.cachedOrders == null ||
                        state.cachedOrders!.isEmpty)) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadOrders(page: 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A99AD),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Coba Lagi',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                List<OrderEntity> orders = [];
                bool hasMore = false;
                bool isPaginationLoading = false;

                if (state is OrderLoaded) {
                  orders = state.orders;
                  hasMore = state.hasMorePages;
                } else if (state is OrderPaginationLoading) {
                  orders = state.orders;
                  hasMore = true;
                  isPaginationLoading = true;
                } else if (state is OrderError && state.cachedOrders != null) {
                  orders = state.cachedOrders!;
                }
                if (orders.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A99AD)
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  size: 38,
                                  color: Color(0xFF4A99AD),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum Ada Pesanan',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchController.text.isNotEmpty ||
                                        _selectedStatus != null
                                    ? 'Tidak ada pesanan yang sesuai dengan filter'
                                    : 'Buat order laundry pertama dari kasir',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.5,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CreateOrderPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Buat Order Kasir',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A99AD),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 90),
                  itemCount: orders.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= orders.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: isPaginationLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF4A99AD),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }
                    final order = orders[index];
                    return OrderCardWidget(
                      order: order,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailPage(orderId: order.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
