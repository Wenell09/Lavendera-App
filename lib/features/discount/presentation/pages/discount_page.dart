import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/utils/currency_formatter.dart';
import 'package:lavendera/features/discount/domain/entities/discount.dart';
import 'package:lavendera/features/discount/presentation/bloc/discount_bloc.dart';
import 'package:lavendera/features/discount/presentation/pages/add_discount_page.dart';
import 'package:lavendera/features/discount/presentation/pages/discount_detail_page.dart';

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<DiscountBloc>();
    if (bloc.state is! DiscountLoaded) {
      bloc.add(GetDiscountsRequest());
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

  void _onScroll() {
    if (_isBottom) {
      final bloc = context.read<DiscountBloc>();
      final state = bloc.state;
      if (state is DiscountLoaded && state.hasMorePages) {
        bloc.add(
          GetDiscountsRequest(
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            page: state.currentPage + 1,
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

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final text = query.trim();
      context.read<DiscountBloc>().add(
        GetDiscountsRequest(search: text.isEmpty ? null : text, page: 1),
      );
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Diskon',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87, size: 20),
              onPressed: () {
                final text = _searchController.text.trim();
                context.read<DiscountBloc>().add(
                  GetDiscountsRequest(
                    search: text.isEmpty ? null : text,
                    page: 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Cari diskon...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade400,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF4A99AD),
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.grey.shade400,
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF4A99AD),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                _buildFilterChip('Semua', null),
                const SizedBox(width: 8),
                _buildFilterChip('Persen', 'percentage'),
                const SizedBox(width: 8),
                _buildFilterChip('Fixed', 'fixed'),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DiscountBloc, DiscountState>(
              buildWhen: (previous, current) {
                return current is! DiscountActionError;
              },
              builder: (context, state) {
                if (state is DiscountLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF4A99AD),
                    ),
                  );
                }
                if (state is DiscountError) {
                  final cachedDiscounts = state.cachedDiscounts ?? [];
                  if (cachedDiscounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(state.message, style: AppTextStyles.bodyLarge),
                          TextButton(
                            onPressed: () {
                              final text = _searchController.text.trim();
                              context.read<DiscountBloc>().add(
                                GetDiscountsRequest(
                                  search: text.isEmpty ? null : text,
                                  page: 1,
                                ),
                              );
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }
                }
                List<Discount> discounts = [];
                bool isPaginationLoading = false;
                if (state is DiscountLoaded) {
                  discounts = state.discounts;
                } else if (state is DiscountPaginationLoading) {
                  discounts = state.discounts;
                  isPaginationLoading = true;
                } else if (state is DiscountError) {
                  discounts = state.cachedDiscounts ?? [];
                }
                if (_typeFilter != null) {
                  discounts = discounts
                      .where((d) => d.type == _typeFilter)
                      .toList();
                }
                if (discounts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.discount_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Diskon tidak ditemukan'
                              : 'Belum ada diskon',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Coba kata kunci pencarian yang lain'
                              : 'Tambahkan diskon baru untuk mulai',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: discounts.length + (isPaginationLoading ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= discounts.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF4A99AD),
                            ),
                          ),
                        ),
                      );
                    }
                    final discount = discounts[index];
                    return _buildDiscountCard(context, discount);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDiscountPage()),
          );
        },
        backgroundColor: const Color(0xFF4A99AD),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Diskon',
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountCard(BuildContext context, Discount discount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4A99AD).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.percent, color: Color(0xFF4A99AD)),
            ),
          ),
          title: Text(
            discount.name,
            style: AppTextStyles.titleLarge.copyWith(color: Colors.black87),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  discount.type == 'percentage'
                      ? '${discount.value}%'
                      : CurrencyFormatter.format(discount.value),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: const Color(0xFF4A99AD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: discount.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    discount.isActive ? 'Aktif' : 'Non-aktif',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: discount.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.grey,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiscountDetailPage(discount: discount),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type) {
    final isSelected = _typeFilter == type;
    return InkWell(
      onTap: () => setState(() => _typeFilter = type),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A99AD) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
