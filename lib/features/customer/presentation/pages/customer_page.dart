import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:lavendera/features/customer/presentation/pages/add_customer_page.dart';
import 'package:lavendera/features/customer/presentation/pages/customer_detail_page.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/card_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/empty_widget.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CustomerBloc>();
    if (bloc.state is! CustomerLoaded) {
      bloc.add(GetCustomersRequest());
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
      final bloc = context.read<CustomerBloc>();
      final state = bloc.state;
      if (state is CustomerLoaded && state.hasMorePages) {
        bloc.add(
          GetCustomersRequest(
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
      context.read<CustomerBloc>().add(
        GetCustomersRequest(search: text.isEmpty ? null : text, page: 1),
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
          'Pelanggan',
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
                context.read<CustomerBloc>().add(
                  GetCustomersRequest(
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
                hintText: 'Cari nama atau telepon...',
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
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              buildWhen: (previous, current) {
                return current is! CustomerActionError;
              },
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF4A99AD),
                    ),
                  );
                } else if (state is CustomerError) {
                  final cachedCustomers = state.cachedCustomers ?? [];
                  if (cachedCustomers.isEmpty) {
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
                          Text(
                            state.message,
                            style: AppTextStyles.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _onSearchChanged(_searchController.text);
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  }
                }
                List<Customer> customers = [];
                bool isPaginationLoading = false;
                if (state is CustomerLoaded) {
                  customers = state.customers;
                } else if (state is CustomerPaginationLoading) {
                  customers = state.customers;
                  isPaginationLoading = true;
                } else if (state is CustomerError) {
                  customers = state.cachedCustomers ?? [];
                }
                if (customers.isEmpty) {
                  return EmptyWidget(
                    icon: Icons.people_outline,
                    title: _searchController.text.isNotEmpty
                        ? 'Pelanggan tidak ditemukan'
                        : 'Belum ada pelanggan',
                    subtitle: _searchController.text.isNotEmpty
                        ? 'Coba kata kunci pencarian yang lain'
                        : 'Tambahkan pelanggan baru untuk mulai',
                  );
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: customers.length + (isPaginationLoading ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    // Indikator loading pagination
                    if (index >= customers.length) {
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
                    final customer = customers[index];
                    return CardWidget(
                      padding: EdgeInsets.zero,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CustomerDetailPage(customerId: customer.id),
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A99AD)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              customer.name.isNotEmpty
                                  ? customer.name[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: const Color(0xFF4A99AD),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                customer.phone,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    );
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
            MaterialPageRoute(builder: (context) => const AddCustomerPage()),
          );
        },
        backgroundColor: const Color(0xFF4A99AD),
        elevation: 4,
        foregroundColor: const Color(0xFF4A99AD).withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah',
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
