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
import '../../stock_summary/presentation/pages/stock_summary_screen.dart';
import '../../stock_summary/presentation/cubit/stock_summary_cubit.dart';

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

   
    _salesRepository = getIt<SalesRepositoryImpl>();
    _arpRepository = ArpRepositoryImpl();

 
    final allSidebarItems = [
      SidebarItem(
        id: 'dashboard',
        icon: LucideIcons.layoutDashboard,
        title: "لوحة التحكم",
        screen: DashboardHome(
          onCardTap: (id) => handleCardTap(id),
          isManager: curUser.userType == UserType.manager,
        ),
      ),
      SidebarItem(
        id: 'sales',
        icon: LucideIcons.shoppingCart,
        title: "المبيعات",
        screen: SalesScreen(repository: _salesRepository),
      ),
      SidebarItem(
        id: 'invoices',
        icon: LucideIcons.fileText,
        title: "الفواتير",
        screen: BlocProvider<InvoiceCubit>(
          create: (_) => InvoiceCubit(_salesRepository),
          child:
              InvoiceScreen(repository: _salesRepository, currentUser: curUser),
        ),
      ),
      SidebarItem(
        id: 'products',
        icon: LucideIcons.box,
        title: "المنتجات",
        screen: const ProductsScreen(),
      ),
      SidebarItem(
        id: 'stock_alerts',
        icon: LucideIcons.alertTriangle,
        title: "المنتجات الناقصة",
        screen: const StockScreen(),
      ),
  
      if (curUser.userType != UserType.cashier)
        SidebarItem(
          id: 'stock_summary',
          icon: LucideIcons.clipboardList,
          title: "ملخص المخزون",
          screen: BlocProvider(
            create: (_) => getIt<StockSummaryCubit>()..init(),
            child: const StockSummaryScreen(),
          ),
        ),
      if (curUser.userType == UserType.manager)
        SidebarItem(
          id: 'reports',
          icon: LucideIcons.pieChart,
          title: "التحليلات والتقارير",
          screen: BlocProvider(
            create: (context) => ArpCubit(_arpRepository),
            child: const ArpScreen(),
          ),
        ),
      SidebarItem(
        id: 'notifications',
        icon: LucideIcons.bell,
        title: "التنبيهات",
        screen: const NotificationsScreen(),
      ),
      SidebarItem(
        id: 'settings',
        icon: LucideIcons.settings,
        title: "الإعدادات",
        screen: const SettingsScreen(),
      ),
    ];
    
    sidebarItems = allSidebarItems;
  }

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
                    title: const Text("Bayaa"),
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
    final item = sidebarItems[index];
    if (item.id == 'reports' || item.id == 'stock_summary') {
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
  void handleCardTap(String id) {
    final index = sidebarItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _onSidebarSelected(context, index);
    } else {
      MotionSnackBarWarning(context, "الشاشة غير متاحة");
    }
  }
}
