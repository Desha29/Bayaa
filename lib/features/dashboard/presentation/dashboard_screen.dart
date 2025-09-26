import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../products/presentation/products_screen.dart';
import '../../sales/presentation/sales_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stock/presentation/stock_screen.dart';

// ---------------- Sidebar Item Model ----------------
class SidebarItem {
  final IconData icon;
  final String title;
  final Widget screen;

  SidebarItem({required this.icon, required this.title, required this.screen});
}

// ---------------- Dashboard ----------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  late final List<SidebarItem> sidebarItems = [
    SidebarItem(
      icon: Icons.dashboard,
      title: "لوحة التحكم",
      screen: buildDashboardHome(),
    ),
    SidebarItem(
      icon: Icons.shopping_cart,
      title: "المبيعات",
      screen: const SalesScreen(),
    ),
    SidebarItem(
      icon: Icons.inventory_2,
      title: "المنتجات",
      screen: const ProductsScreen(),
    ),
    SidebarItem(
      icon: Icons.warning,
      title: "المنتجات الناقصة",
      screen: const StockScreen(),
    ),
    SidebarItem(
      icon: Icons.notifications,
      title: "التنبيهات",
      screen: const NotificationsScreen(),
    ),
    SidebarItem(
      icon: Icons.settings,
      title: "الإعدادات",
      screen: const SettingsScreen(),
    ),
  ];

  Widget buildDashboardHome() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        double aspectRatio = 1.2;

        if (constraints.maxWidth < 600) {
          crossAxisCount = 1; // Mobile => one card per row (smaller)
          aspectRatio = 1.8;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2; // Tablet => two cards per row
          aspectRatio = 1.6;
        }

        // helper to handle tapping a card: update sidebar selection and close drawer if open
        void handleCardTap(int targetIndex) {
          setState(() {
            selectedIndex = targetIndex;
          });
          final scaffoldState = Scaffold.maybeOf(context);
          if (scaffoldState != null && scaffoldState.isDrawerOpen) {
            Navigator.of(context).pop(); // close drawer on mobile/tablet
          }
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "لوحة التحكم",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "مرحباً بك في نظام Crazy Phone لإدارة نقاط البيع",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),

              // Cards Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: aspectRatio,
                  children: [
                    // Notifications -> sidebar index 4
                    buildDashboardCard(
                      icon: Icons.notifications,
                      title: "التنبيهات",
                      subtitle: "الإشعارات والتنبيهات",
                      color: AppColors.primaryColor,
                      onTap: () => handleCardTap(4),
                    ),
                    // Low Stock -> sidebar index 3
                    buildDashboardCard(
                      icon: Icons.warning,
                      title: "المنتجات الناقصة",
                      subtitle: "تنبيهات المخزون",
                      color: AppColors.warningColor,
                      onTap: () => handleCardTap(3),
                    ),
                    // Products -> sidebar index 2
                    buildDashboardCard(
                      icon: Icons.inventory_2,
                      title: "المنتجات",
                      subtitle: "إدارة المخزون",
                      color: AppColors.successColor,
                      onTap: () => handleCardTap(2),
                    ),
                    // Sales -> sidebar index 1
                    buildDashboardCard(
                      icon: Icons.shopping_cart,
                      title: "المبيعات",
                      subtitle: "إدارة عمليات البيع",
                      color: AppColors.primaryColor,
                      onTap: () => handleCardTap(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderColor),
      ),
      child: InkWell(
        onTap: onTap, // now uses provided callback (was empty before)
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSidebar() {
    return Container(
      width: 240,
      color: AppColors.kCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.phone_android,
            size: 48,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 12),
          const Text(
            "Crazy Phone",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.secondaryColor,
            ),
          ),
          const Text(
            "نظام نقاط البيع",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedColor),
          ),
          const SizedBox(height: 30),

          // Sidebar items
          Expanded(
            child: ListView.builder(
              itemCount: sidebarItems.length,
              itemBuilder: (context, index) {
                final item = sidebarItems[index];
                final isSelected = index == selectedIndex;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected
                          ? AppColors.primaryForeground
                          : AppColors.mutedColor,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryForeground
                            : AppColors.secondaryColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      if (MediaQuery.of(context).size.width < 1000) {
                        Navigator.pop(context); // Close drawer on mobile/tablet
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(color: AppColors.borderColor),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorColor),
            title: const Text(
              "تسجيل الخروج",
              style: TextStyle(color: AppColors.errorColor),
            ),
            onTap: () {
              // TODO: Logout Logic
            },
          ),
        ],
      ),
    );
  }

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
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              )
            : null,
        drawer: isMobileOrTablet ? Drawer(child: buildSidebar()) : null,
        body: Row(
          children: [
            if (!isMobileOrTablet) buildSidebar(),
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
}
