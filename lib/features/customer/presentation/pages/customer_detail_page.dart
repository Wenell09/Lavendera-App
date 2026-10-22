import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/features/customer/presentation/bloc/action/customer_action_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:lavendera/features/customer/presentation/bloc/detail/customer_detail_bloc.dart';
import 'package:lavendera/features/customer/presentation/pages/edit_customer_page.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/dialog_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/info_tile_widget.dart';

class CustomerDetailPage extends StatelessWidget {
  final String customerId;
  const CustomerDetailPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<CustomerDetailBloc>()..add(GetCustomerByIdRequest(id: customerId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            BlocBuilder<CustomerDetailBloc, CustomerDetailState>(
              builder: (context, state) {
                if (state is! CustomerDetailLoaded) {
                  return const SizedBox.shrink();
                }
                final customer = state.customer;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.black87,
                      size: 20,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditCustomerPage(customer: customer),
                      ),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<CustomerDetailBloc, CustomerDetailState>(
              builder: (context, state) {
                if (state is! CustomerDetailLoaded) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () =>
                        _showDeleteDialog(context, state.customer.id),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocListener<CustomerActionBloc, CustomerActionState>(
          listener: (context, state) {
            if (state is CustomerActionSuccess) {
              context.read<CustomerBloc>().add(GetCustomersRequest());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                  dismissDirection: DismissDirection.horizontal,
                ),
              );
            } else if (state is CustomerActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  dismissDirection: DismissDirection.horizontal,
                ),
              );
            }
          },
          child: BlocBuilder<CustomerDetailBloc, CustomerDetailState>(
            builder: (context, state) {
              if (state is CustomerDetailLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF4A99AD),
                  ),
                );
              }
              if (state is CustomerDetailError) {
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
                        textAlign: .center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          final detailBloc = context.read<CustomerDetailBloc>();
                          final parent = context
                              .findAncestorWidgetOfExactType<
                                CustomerDetailPage
                              >();
                          if (parent != null) {
                            detailBloc.add(
                              GetCustomerByIdRequest(id: parent.customerId),
                            );
                          }
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }
              if (state is CustomerDetailLoaded) {
                final customer = state.customer;
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A99AD).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Center(
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.displayLarge.copyWith(
                              color: const Color(0xFF4A99AD),
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        customer.name,
                        style: AppTextStyles.displaySmall.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            InfoTileWidget(
                              icon: Icons.phone_outlined,
                              label: 'Nomor Telepon',
                              value: customer.phone,
                            ),
                            const Divider(height: 32, thickness: 0.5),
                            InfoTileWidget(
                              icon: Icons.location_on_outlined,
                              label: 'Alamat Lengkap',
                              value: customer.address ?? 'Alamat belum diatur',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            InfoTileWidget(
                              icon: Icons.calendar_today_outlined,
                              label: 'Bergabung Sejak',
                              value: _formatDate(customer.createdAt),
                              iconColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String customerId) async {
    final confirmed = await DialogWidget.showDeleteConfirmation(
      context,
      title: 'Hapus Pelanggan?',
      content: 'Tindakan ini tidak dapat dibatalkan. Semua data terkait pelanggan ini akan hilang.',
    );
    if (confirmed == true && context.mounted) {
      context.read<CustomerActionBloc>().add(
        DeleteCustomerActionRequest(id: customerId),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
