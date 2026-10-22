import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/info_tile_widget.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet/presentation/bloc/outlet_bloc.dart';
import 'package:lavendera/features/outlet/presentation/pages/edit_outlet_page.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Outlet'),
        content: Text('Anda yakin ingin menghapus outlet "${_outlet.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<OutletBloc>().add(
                DeleteOutletRequest(id: _outlet.id),
              );
              Navigator.pop(context);
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
        actions: [
          Container(
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
                  builder: (context) => EditOutletPage(outlet: _outlet),
                ),
              ),
            ),
          ),
          Container(
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
              onPressed: () => _showDeleteDialog(context),
            ),
          ),
        ],
      ),
      body: BlocListener<OutletBloc, OutletState>(
        listener: (context, state) {
          if (state is OutletActionSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
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
                  color: const Color(0xFF4A99AD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 50,
                    color: Color(0xFF4A99AD),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _outlet.name,
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
                      icon: Icons.link_outlined,
                      label: 'Slug',
                      value: _outlet.slug,
                    ),
                    const Divider(height: 32, thickness: 0.5),
                    InfoTileWidget(
                      icon: Icons.phone_outlined,
                      label: 'Nomor Telepon',
                      value: _outlet.phone,
                    ),
                    const Divider(height: 32, thickness: 0.5),
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
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
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
                    const Divider(height: 32, thickness: 0.5),
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
            ],
          ),
        ),
      ),
    );
  }
}
