import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../products/presentation/products_screen.dart';
import '../../sales/presentation/sales_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stock/presentation/stock_screen.dart';

import 'widgets/dashboard_home.dart';
import 'widgets/side_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  bool isSidebarCollapsed = false;

  late final List<SidebarItem> sidebarItems = [
    SidebarItem(
      icon: LucideIcons.layoutDashboard,
      title: "لوحة التحكم",
      screen: DashboardHome(
        onCardTap: (selectedIndex) => handleCardTap(selectedIndex),
      ),
    ),
    SidebarItem(
      icon: LucideIcons.shoppingCart,
      title: "المبيعات",
      screen: const SalesScreen(),
    ),
    SidebarItem(
      icon: LucideIcons.box,
      title: "المنتجات",
      screen: const ProductsScreen(),
    ),
    SidebarItem(
      icon: LucideIcons.alertTriangle,
      title: "المنتجات الناقصة",
      screen: const StockScreen(),
    ),
    SidebarItem(
      icon: LucideIcons.bell,
      title: "التنبيهات",
      screen: const NotificationsScreen(),
    ),
    SidebarItem(
      icon: LucideIcons.settings,
      title: "الإعدادات",
      screen: const SettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobileOrTablet = MediaQuery.of(context).size.width < 1000;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: isMobileOrTablet
            ? AppBar(
                backgroundColor: AppColors.primaryColor,
                title: const Text("Crazy Phone"),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(LucideIcons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              )
            : null,
        drawer: isMobileOrTablet
            ? Drawer(
                child: CustomSidebar(
                  items: sidebarItems,
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
            : null,
        body: Row(
          children: [
            if (!isMobileOrTablet)
              CustomSidebar(
                items: sidebarItems,
                selectedIndex: selectedIndex,
                isCollapsed: isSidebarCollapsed,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            Expanded(
              child: Container(
                color: AppColors.backgroundColor,
                child: sidebarItems[selectedIndex].screen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles tap on a card in the dashboard screen.
  void handleCardTap(int targetIndex) {
    setState(() {
      selectedIndex = targetIndex;
    });
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null && scaffoldState.isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }
}
