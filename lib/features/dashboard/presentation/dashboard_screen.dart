// lib/features/dashboard/presentation/dashboard_screen.dart
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/functions/messege.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../products/presentation/products_screen.dart';
import '../../products/data/models/product_model.dart';
import '../../sales/data/repository/sales_repository_impl.dart';
import '../../sales/presentation/sales_screen.dart';
import '../../sales/data/models/sale_model.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stock/presentation/stock_screen.dart';
import '../../invoice/presentation/invoices_home.dart';

// ARP imports
import '../../arp/presentation/screens/arp_screen.dart';
import '../../arp/presentation/cubit/arp_cubit.dart';
import '../../arp/data/arp_repository_impl.dart';

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

  // Open Hive boxes and create repositories
  late final Box<Product> _productsBox;
  late final Box<Sale> _salesBox;
  late final SalesRepositoryImpl _salesRepository;
  late final ArpRepositoryImpl _arpRepository;

  @override
  void initState() {
    super.initState();
    _productsBox = Hive.box<Product>('productsBox');
    _salesBox = Hive.box<Sale>('salesBox');
    _salesRepository = SalesRepositoryImpl(
      productsBox: _productsBox,
      salesBox: _salesBox,
    );

    // Only needs sales repository
    _arpRepository = ArpRepositoryImpl(
      salesRepository: _salesRepository,
    );
  }

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
      screen: SalesScreen(repository: _salesRepository),
    ),
    SidebarItem(
      icon: LucideIcons.fileText,
      title: "الفواتير",
      screen: InvoicesHome(repository: _salesRepository),
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
    // ARP Screen with BlocProvider
    SidebarItem(
      icon: LucideIcons.pieChart,
      title: "التحليلات والتقارير",
      screen: BlocProvider(
        create: (context) => ArpCubit(_arpRepository),
        child: const ArpScreen(),
      ),
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

    return MultiBlocProvider(
      providers: [
        BlocProvider<StockCubit>.value(
          value: getIt<StockCubit>()..loadData(),
        ),
        BlocProvider<NotificationsCubit>.value(
          value: getIt<NotificationsCubit>()..loadData(),
        ),
      ],
      child: BlocListener<NotificationsCubit, NotificationsStates>(
        listener: (context, state) {
          if (state is NotificationsError) {
            MotionSnackBarWarning(context, state.message);
          }
        },
        child: Directionality(
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
