// lib/features/dashboard/presentation/dashboard_screen.dart
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/functions/messege.dart';
import '../../../core/security/permission_guard.dart';
import '../../auth/presentation/cubit/user_cubit.dart';
import '../../invoice/presentation/cubit/invoice_cubit.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../products/presentation/products_screen.dart';
import '../../sales/data/repository/sales_repository_impl.dart';
import '../../sales/presentation/cubit/sales_cubit.dart';
import '../../sales/presentation/sales_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stock/presentation/stock_screen.dart';
import '../../invoice/presentation/invoices_screen.dart';

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

  late final SalesRepositoryImpl _salesRepository;
  late final ArpRepositoryImpl _arpRepository;
  late final User curUser = getIt<UserCubit>().currentUser;
  late final List<SidebarItem> sidebarItems;

  @override
  void initState() {
    super.initState();

    // Resolve repositories once via DI
    _salesRepository = getIt<SalesRepositoryImpl>();
    _arpRepository = ArpRepositoryImpl();

    // Build sidebar items once
    sidebarItems = [
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
        screen: BlocProvider<InvoiceCubit>(
          create: (_) => InvoiceCubit(_salesRepository),
          child:
              InvoiceScreen(repository: _salesRepository, currentUser: curUser),
        ),
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
  }

  @override
  Widget build(BuildContext context) {
    // Ensuring sidebarItems is initialized. didChangeDependencies called before build.
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
                    title: const Text("Amr Store"),
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
                      onItemSelected: (index) => _onSidebarSelected(context, index),
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
                    onItemSelected: (index) => _onSidebarSelected(context, index),
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
  
  void _onSidebarSelected(BuildContext context, int index) {
      if (index == 5) { // Report index
          try {
              PermissionGuard.checkReportAccess(curUser);
          } catch (e) {
              MotionSnackBarError(context, e.toString());
              return;
          }
      }
      
      setState(() {
          selectedIndex = index;
      });
      
      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
          Navigator.pop(context);
      }
  }

  /// Handles tap on a card in the dashboard screen.
  void handleCardTap(int targetIndex) {
    _onSidebarSelected(context, targetIndex);
  }
}
