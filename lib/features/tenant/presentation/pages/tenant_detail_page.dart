import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/colors/app_colors.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/features/tenant/presentation/bloc/action/tenant_action_bloc.dart';
import 'package:lavendera/features/tenant/presentation/bloc/detail/tenant_detail_bloc.dart';
import 'package:lavendera/features/tenant/presentation/pages/edit_tenant_page.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/info_tile_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/card_widget.dart';

class TenantDetailPage extends StatelessWidget {
  final String tenantId;
  const TenantDetailPage({super.key, required this.tenantId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<TenantDetailBloc>()..add(GetTenantRequest(id: tenantId)),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Informasi Bisnis',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            BlocBuilder<TenantDetailBloc, TenantDetailState>(
              builder: (context, state) {
                if (state is TenantDetailLoaded) {
                  return IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.black87),
                    onPressed: () => context.read<TenantDetailBloc>().add(GetTenantRequest(id: tenantId)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocListener<TenantActionBloc, TenantActionState>(
          listener: (context, state) {
            if (state is TenantActionSuccess) {
              context.read<TenantDetailBloc>().add(GetTenantRequest(id: tenantId));
            }
          },
          child: BlocBuilder<TenantDetailBloc, TenantDetailState>(
            builder: (context, state) {
              if (state is TenantDetailLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4A99AD),
                  ),
                );
              }

              if (state is TenantDetailError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade200),
                        const SizedBox(height: 16),
                        Text(state.message, style: AppTextStyles.bodyLarge, textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.read<TenantDetailBloc>().add(GetTenantRequest(id: tenantId)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue.color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is TenantDetailLoaded) {
                final tenant = state.tenant;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, tenant),
                      const SizedBox(height: 32),
                      Text(
                        'Detail Tenant',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CardWidget(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            InfoTileWidget(
                              icon: Icons.business_outlined,
                              label: 'Nama Bisnis',
                              value: tenant.name,
                            ),
                            const Divider(height: 32, thickness: 0.5),
                            InfoTileWidget(
                              icon: Icons.link_outlined,
                              label: 'Slug / URL',
                              value: '/${tenant.slug}',
                            ),
                            const Divider(height: 32, thickness: 0.5),
                            InfoTileWidget(
                              icon: Icons.email_outlined,
                              label: 'Email Admin',
                              value: tenant.email,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Informasi Sistem',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CardWidget(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            InfoTileWidget(
                              icon: Icons.calendar_today_outlined,
                              label: 'Terdaftar Pada',
                              value: _formatDate(tenant.createdAt),
                              iconColor: Colors.grey,
                            ),
                            const Divider(height: 32, thickness: 0.5),
                            InfoTileWidget(
                              icon: Icons.update_outlined,
                              label: 'Pembaruan Terakhir',
                              value: _formatDate(tenant.updatedAt),
                              iconColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTenantPage(tenant: tenant),
                              ),
                            );
                            if (updated == true && context.mounted) {
                              context.read<TenantDetailBloc>().add(GetTenantRequest(id: tenantId));
                            }
                          },
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          label: const Text('Edit Profil Bisnis'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
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

  Widget _buildHeader(BuildContext context, dynamic tenant) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.blue.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                tenant.name[0].toUpperCase(),
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.blue.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tenant.name,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '@${tenant.slug}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
