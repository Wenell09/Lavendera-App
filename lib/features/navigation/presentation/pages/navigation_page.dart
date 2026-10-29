import 'package:flutter/material.dart';
import 'package:lavendera/features/order/presentation/pages/create_order_page.dart';
import 'package:lavendera/features/order/presentation/pages/order_page.dart';
import 'package:lavendera/features/profile/presentation/pages/profile_detail_page.dart';
import 'package:lavendera/home_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final List<Widget> _pages = const [
    HomePage(),
    OrderPage(),
    CreateOrderPage(),
    ProfileDetailPage(),
  ];

  int index = 0;

  static const Color primaryColor = Color(0xFF4A99AD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: 'Order',
          ),
          NavigationDestination(
            icon: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            selectedIcon: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
