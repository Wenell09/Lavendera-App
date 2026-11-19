import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/core/di/injection.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/card_widget.dart';
import 'package:lavendera/features/customer/presentation/pages/widgets/info_tile_widget.dart';
import 'package:lavendera/features/tenant/presentation/bloc/action/tenant_action_bloc.dart';
import 'package:lavendera/features/tenant/presentation/bloc/detail/tenant_detail_bloc.dart';
import 'package:lavendera/features/tenant/presentation/pages/edit_tenant_page.dart';

class TenantDetailPage extends StatelessWidget {
  final String tenantId;
  const TenantDetailPage({super.key, required this.tenantId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<TenantDetailBloc>()..add(GetTenantRequest(id: tenantId)),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Informasi Bisnis',
            style: AppTextStyles.headlineMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            BlocBuilder<TenantDetailBloc, TenantDetailState>(
              builder: (context, state) {
                if (state is TenantDetailLoaded) {
                  return IconButton(
                    icon: Icon(Icons.refresh, color: colorScheme.onSurface),
                    onPressed: () => context.read<TenantDetailBloc>().add(
                      GetTenantRequest(id: tenantId),
                    ),
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
              context.read<TenantDetailBloc>().add(
                GetTenantRequest(id: tenantId),
              );
            }
          },
          child: BlocBuilder<TenantDetailBloc, TenantDetailState>(
            builder: (context, state) {
              if (state is TenantDetailLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
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
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.read<TenantDetailBloc>().add(
                            GetTenantRequest(id: tenantId),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Coba Lagi',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
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
                          color: colorScheme.onSurface,
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
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            InfoTileWidget(
                              icon: Icons.link_outlined,
                              label: 'Slug / URL',
                              value: '/${tenant.slug}',
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
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
                          color: colorScheme.onSurface,
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
                              iconColor: colorScheme.onSurfaceVariant,
                            ),
                            Divider(
                              height: 32,
                              thickness: 0.5,
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            InfoTileWidget(
                              icon: Icons.update_outlined,
                              label: 'Pembaruan Terakhir',
                              value: _formatDate(tenant.updatedAt),
                              iconColor: colorScheme.onSurfaceVariant,
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
                                builder: (context) =>
                                    EditTenantPage(tenant: tenant),
                              ),
                            );
                            if (updated == true && context.mounted) {
                              context.read<TenantDetailBloc>().add(
                                GetTenantRequest(id: tenantId),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: colorScheme.onPrimary,
                          ),
                          label: Text(
                            'Edit Profil Bisnis',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                tenant.name[0].toUpperCase(),
                style: AppTextStyles.displaySmall.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            tenant.name,
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                    : Colors.grey.shade200,
              ),
            ),
            child: Text(
              '@${tenant.slug}',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
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
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
