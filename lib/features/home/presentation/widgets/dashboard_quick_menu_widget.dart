import 'package:flutter/material.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/pages/customer_page.dart';
import 'package:lavendera/features/discount/presentation/pages/discount_page.dart';
import 'package:lavendera/features/outlet/presentation/pages/outlet_page.dart';
import 'package:lavendera/features/profile/domain/entities/profile.dart';
import 'package:lavendera/features/service/presentation/pages/service_page.dart';
import 'package:lavendera/features/service_category/presentation/pages/service_category_page.dart';
import 'package:lavendera/features/tenant/presentation/pages/tenant_detail_page.dart';
import 'package:lavendera/features/user/presentation/pages/user_page.dart';

class DashboardQuickMenuWidget extends StatelessWidget {
  final Profile? profile;

  const DashboardQuickMenuWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4A99AD);
    final isAdmin = (profile?.role.toUpperCase() ?? '') == 'ADMIN';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menu Operasional',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Icon(Icons.grid_view_rounded, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 14),
          // Operations Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 500 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.1,
                children: [
                  _buildMenuItem(
                    context: context,
                    title: 'Kategori Layanan',
                    icon: Icons.category_rounded,
                    color: primaryColor,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ServiceCategoryPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    title: 'Layanan',
                    icon: Icons.local_laundry_service_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ServicePage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    title: 'Pelanggan',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CustomerPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    title: 'Diskon',
                    icon: Icons.percent_rounded,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DiscountPage(),
                        ),
                      );
                    },
                  ),
                  if (isAdmin) ...[
                    _buildMenuItem(
                      context: context,
                      title: 'Outlet',
                      icon: Icons.store_rounded,
                      color: const Color(0xFF0D9488),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const OutletPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      title: 'Staff',
                      icon: Icons.badge_rounded,
                      color: const Color(0xFFEC4899),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UserPage(),
                          ),
                        );
                      },
                    ),
                    if (profile?.tenantId != null &&
                        profile!.tenantId.isNotEmpty)
                      _buildMenuItem(
                        context: context,
                        title: 'Tenant',
                        icon: Icons.domain_rounded,
                        color: const Color(0xFF8B5CF6),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TenantDetailPage(tenantId: profile!.tenantId),
                            ),
                          );
                        },
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 12.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
