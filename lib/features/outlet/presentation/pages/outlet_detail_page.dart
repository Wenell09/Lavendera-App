import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/card_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/info_tile_widget.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet/presentation/bloc/action/outlet_action_bloc.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';
import 'package:lavendera/features/outlet/presentation/pages/edit_outlet_page.dart';
import 'package:lavendera/features/outlet_payment_method/presentation/pages/outlet_payment_method_page.dart';
import 'package:lavendera/features/outlet_user/presentation/pages/outlet_user_page.dart';

class OutletDetailPage extends StatelessWidget {
  final Outlet outlet;
  const OutletDetailPage({super.key, required this.outlet});

  @override
  Widget build(BuildContext context) {
    return _OutletDetailView(outlet: outlet);
  }
}

class _OutletDetailView extends StatefulWidget {
  final Outlet outlet;
  const _OutletDetailView({required this.outlet});

  @override
  State<_OutletDetailView> createState() => _OutletDetailViewState();
}

class _OutletDetailViewState extends State<_OutletDetailView> {
  late Outlet _outlet;

  @override
  void initState() {
    super.initState();
    _outlet = widget.outlet;
  }

  void _showDeleteDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Outlet',
          style: AppTextStyles.headlineSmall.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Anda yakin ingin menghapus outlet "${_outlet.name}"?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<OutletActionBloc>().add(
                DeleteOutletActionRequest(id: _outlet.id),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Hapus',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditOutletPage(outlet: _outlet),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
                size: 20,
              ),
              onPressed: () => _showDeleteDialog(context),
            ),
          ),
        ],
      ),
      body: BlocListener<OutletActionBloc, OutletActionState>(
        listener: (context, state) {
          if (state is OutletActionSuccess) {
            context.read<OutletBloc>().add(GetOutletsRequest());
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          } else if (state is OutletActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
                dismissDirection: DismissDirection.horizontal,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 50,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _outlet.name,
                style: AppTextStyles.displaySmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surfaceContainer : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                        : Colors.grey.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.02,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InfoTileWidget(
                      icon: Icons.link_outlined,
                      label: 'Slug',
                      value: _outlet.slug,
                    ),
                    Divider(
                      height: 32,
                      thickness: 0.5,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    InfoTileWidget(
                      icon: Icons.phone_outlined,
                      label: 'Nomor Telepon',
                      value: _outlet.phone,
                    ),
                    Divider(
                      height: 32,
                      thickness: 0.5,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    InfoTileWidget(
                      icon: Icons.location_on_outlined,
                      label: 'Alamat',
                      value: _outlet.address,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surfaceContainer : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                        : Colors.grey.shade100,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.02,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InfoTileWidget(
                      icon: _outlet.isPublicOrderEnabled
                          ? Icons.public
                          : Icons.public_off,
                      label: 'Order Publik',
                      value: _outlet.isPublicOrderEnabled
                          ? 'Aktif'
                          : 'Non-aktif',
                    ),
                    Divider(
                      height: 32,
                      thickness: 0.5,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                    InfoTileWidget(
                      icon: _outlet.isActive
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      label: 'Status',
                      value: _outlet.isActive ? 'Aktif' : 'Non-aktif',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CardWidget(
                padding: const EdgeInsets.all(20),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OutletUserPage(outlet: _outlet),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.people_outline,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staf & Pengguna',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Kelola staf yang bertugas di outlet ini',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CardWidget(
                padding: const EdgeInsets.all(20),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OutletPaymentMethodPage(outlet: _outlet),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.payment_outlined,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Metode Pembayaran',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Kelola transfer bank dan QRIS outlet ini',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
