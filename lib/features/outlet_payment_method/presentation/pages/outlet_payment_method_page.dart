import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/card_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/empty_widget.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/action/outlet_payment_method_action_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/bloc/outlet_payment_method_bloc.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/pages/add_edit_outlet_payment_method_page.dart';

class OutletPaymentMethodPage extends StatefulWidget {
  final Outlet outlet;

  const OutletPaymentMethodPage({super.key, required this.outlet});

  @override
  State<OutletPaymentMethodPage> createState() =>
      _OutletPaymentMethodPageState();
}

class _OutletPaymentMethodPageState extends State<OutletPaymentMethodPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OutletPaymentMethodBloc>().add(
      GetOutletPaymentMethodsRequest(outletId: widget.outlet.id),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, OutletPaymentMethod pm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Metode Pembayaran'),
        content: Text('Yakin ingin menghapus ${pm.providerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<OutletPaymentMethodActionBloc>().add(
                DeleteOutletPaymentMethodActionRequest(
                  outletId: widget.outlet.id,
                  paymentMethodId: pm.id,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          'Metode Pembayaran',
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                context.read<OutletPaymentMethodBloc>().add(
                  GetOutletPaymentMethodsRequest(
                    outletId: widget.outlet.id,
                    search: text.isEmpty ? null : text,
                    page: 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<
            OutletPaymentMethodActionBloc,
            OutletPaymentMethodActionState
          >(
            listener: (context, state) {
              if (state is OutletPaymentMethodActionSuccess) {
                context.read<OutletPaymentMethodBloc>().add(
                  GetOutletPaymentMethodsRequest(outletId: widget.outlet.id),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is OutletPaymentMethodActionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<OutletPaymentMethodBloc>().add(
                    GetOutletPaymentMethodsRequest(
                      outletId: widget.outlet.id,
                      search: value,
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama provider...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<OutletPaymentMethodBloc, OutletPaymentMethodState>(
                builder: (context, state) {
                  if (state is OutletPaymentMethodLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<OutletPaymentMethod> list = [];
                  if (state is OutletPaymentMethodLoaded) {
                    list = state.paymentMethods;
                  } else if (state is OutletPaymentMethodError) {
                    list = state.cachedPaymentMethods ?? [];
                  }

                  if (list.isEmpty) {
                    return const EmptyWidget(
                      icon: Icons.payment_outlined,
                      title: 'Belum Ada Metode Pembayaran',
                      subtitle: 'Tambahkan metode pembayaran untuk transaksi outlet ini.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final pm = list[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CardWidget(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A99AD)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  pm.type == 'qris'
                                      ? Icons.qr_code
                                      : Icons.account_balance,
                                  color: const Color(0xFF4A99AD),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          pm.providerName,
                                          style: AppTextStyles.titleMedium
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: pm.isActive
                                                ? Colors.green.shade50
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            pm.isActive ? 'Aktif' : 'Non-aktif',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: pm.isActive
                                                  ? Colors.green
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pm.type == 'bank_transfer'
                                          ? '${pm.accountNumber} (${pm.accountName})'
                                          : pm.accountName,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddEditOutletPaymentMethodPage(
                                            outlet: widget.outlet,
                                            paymentMethod: pm,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _showDeleteDialog(context, pm),
                              ),
                            ],
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddEditOutletPaymentMethodPage(outlet: widget.outlet),
            ),
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
}
