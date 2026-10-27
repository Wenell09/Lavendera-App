import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/config/typography/app_text_styles.dart';
import 'package:lavendera/features/customer/presentation/pages/customer_page.dart';
import 'package:lavendera/features/discount/presentation/pages/discount_page.dart';
import 'package:lavendera/features/order/presentation/pages/order_page.dart';
import 'package:lavendera/features/outlet/presentation/pages/outlet_page.dart';
import 'package:lavendera/features/profile/presentation/bloc/profile_detail_bloc.dart';
import 'package:lavendera/features/profile/presentation/pages/profile_detail_page.dart';
import 'package:lavendera/features/service/presentation/pages/service_page.dart';
import 'package:lavendera/features/service_category/presentation/pages/service_category_page.dart';
import 'package:lavendera/features/tenant/presentation/pages/tenant_detail_page.dart';
import 'package:lavendera/features/user/presentation/pages/user_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4A99AD);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Lavendera',
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              'Manajemen Laundry',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilih modul untuk mengelola operasional laundry Anda',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ProfileDetailBloc, ProfileDetailState>(
              builder: (context, state) {
                if (state is ProfileDetailLoaded) {
                  return _buildMenuCard(
                    context: context,
                    title: 'Tenant',
                    subtitle: 'Kelola tenant',
                    icon: Icons.person,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TenantDetailPage(
                            tenantId: state.profile.tenantId,
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 14),
            BlocBuilder<ProfileDetailBloc, ProfileDetailState>(
              builder: (context, state) {
                if (state is ProfileDetailLoaded) {
                  return _buildMenuCard(
                    context: context,
                    title: 'Profile',
                    subtitle: 'profile',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileDetailPage(profileId: state.profile.id),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              context: context,
              title: 'Pesanan (Order Kasir)',
              subtitle:
                  'Kelola order laundry, pembayaran, dan status pengerjaan',
              icon: Icons.receipt_long_rounded,
              color: const Color(0xFF0284C7),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const OrderPage()),
                );
              },
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              context: context,
              title: 'Kategori Layanan',
              subtitle:
                  'Kelola kategori service seperti Kiloan, Dry Clean, dll.',
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
            const SizedBox(height: 14),
            _buildMenuCard(
              context: context,
              title: 'Layanan',
              subtitle: 'Kelola jenis layanan laundry, harga, unit, dan durasi',
              icon: Icons.local_laundry_service_rounded,
              color: const Color(0xFF6366F1),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ServicePage()),
                );
              },
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              context: context,
              title: 'Pelanggan',
              subtitle: 'Data kontak, alamat, dan riwayat pelanggan laundry',
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CustomerPage()),
                );
              },
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              context: context,
              title: 'Diskon',
              subtitle: 'Promosi, voucher, dan potongan harga khusus',
              icon: Icons.percent_rounded,
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DiscountPage()),
                );
              },
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              context: context,
              title: 'Outlet',
              subtitle: 'Kelola outlet cabang',
              icon: Icons.store,
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const OutletPage()),
                );
              },
            ),
            const SizedBox(height: 14),
            _buildMenuCard(
              context: context,
              title: 'Staff',
              subtitle: 'Kelola staff',
              icon: Icons.person,
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Icon(icon, color: color, size: 26)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey.shade500,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
