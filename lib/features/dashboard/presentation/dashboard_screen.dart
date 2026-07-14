// lib/features/dashboard/presentation/dashboard_screen.dart
import 'package:bayaa_pos/features/auth/data/models/user_model.dart';
import 'package:bayaa_pos/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:bayaa_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:bayaa_pos/features/stock/presentation/cubit/stock_cubit.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/components/screen_header.dart';
import '../../../core/components/local_image_view.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../core/functions/messege.dart';
import '../../../core/security/permission_guard.dart';
import '../../../core/localization/translation_helper.dart';
import '../../../core/localization/locale_provider.dart';
import '../../auth/presentation/cubit/user_cubit.dart';
import '../../auth/presentation/cubit/user_states.dart';
import '../../settings/presentation/widgets/add_edit_user_dialog.dart';
import '../../invoice/presentation/cubit/invoice_cubit.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../products/presentation/cubit/product_cubit.dart';
import '../../products/presentation/products_screen.dart';
import '../../sales/data/repository/sales_repository_impl.dart';

import '../../sales/presentation/sales_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../stock/presentation/cubit/stock_states.dart';
import '../../stock/presentation/stock_screen.dart';
import '../../invoice/presentation/invoices_screen.dart';

import '../../sessions/presentation/screens/sessions_dashboard_screen.dart';
import '../../analytics/presentation/screens/analytics_screen.dart';
import '../../analytics/presentation/cubit/analytics_cubit.dart';
import '../../analytics/data/analytics_repository_impl.dart';

import 'widgets/dashboard_home.dart';
import 'widgets/side_bar.dart';
import '../../stock_summary/presentation/screens/stock_summary_screen.dart';
import '../../stock_summary/presentation/cubit/stock_summary_cubit.dart';
import '../../expenses/presentation/expenses_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  bool isSidebarCollapsed = false;

  late final SalesRepositoryImpl _salesRepository;
  late final AnalyticsRepositoryImpl _analyticsRepository;
  User get curUser => getIt<UserCubit>().currentUser;

  List<SidebarItem> get sidebarItems => _getSidebarItems(context);

  @override
  void initState() {
    super.initState();

    _salesRepository = getIt<SalesRepositoryImpl>();
    _analyticsRepository = AnalyticsRepositoryImpl();
  }

  List<SidebarItem> _getSidebarItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      SidebarItem(
        id: 'dashboard',
        icon: LucideIcons.layoutDashboard,
        title: l10n.dashboard,
        screen: DashboardHome(
          onCardTap: (id) => handleCardTap(id),
          isManager: curUser.userType == UserType.manager,
        ),
      ),
      SidebarItem(
        id: 'sales',
        icon: LucideIcons.shoppingCart,
        title: l10n.sales,
        screen: SalesScreen(repository: _salesRepository),
      ),
      SidebarItem(
        id: 'invoices',
        icon: LucideIcons.fileText,
        title: l10n.invoices,
        screen: BlocProvider<InvoiceCubit>(
          create: (_) => InvoiceCubit(_salesRepository),
          child:
              InvoiceScreen(repository: _salesRepository, currentUser: curUser),
        ),
      ),
      SidebarItem(
        id: 'products',
        icon: LucideIcons.box,
        title: l10n.products,
        screen: const ProductsScreen(),
      ),
      SidebarItem(
        id: 'stock_alerts',
        icon: LucideIcons.triangleAlert,
        title: l10n.stockAlerts,
        screen: const StockScreen(),
      ),
      if (curUser.userType != UserType.cashier)
        SidebarItem(
          id: 'stock_summary',
          icon: LucideIcons.clipboardList,
          title: l10n.stockSummary,
          screen: BlocProvider(
            create: (_) => getIt<StockSummaryCubit>()..init(),
            child: const StockSummaryScreen(),
          ),
        ),
      if (curUser.userType == UserType.manager)
        SidebarItem(
          id: 'reports',
          icon: LucideIcons.chartPie,
          title: l10n.reports,
          screen: BlocProvider(
            create: (context) => AnalyticsCubit(_analyticsRepository),
            child: const AnalyticsScreen(),
          ),
        ),
      if (curUser.userType == UserType.manager)
        SidebarItem(
          id: 'sessions',
          icon: LucideIcons.history,
          title: l10n.sessions,
          screen: BlocProvider(
            create: (context) => AnalyticsCubit(_analyticsRepository),
            child: const SessionsDashboardScreen(),
          ),
        ),
      SidebarItem(
        id: 'notifications',
        icon: LucideIcons.bell,
        title: l10n.notifications,
        screen: const NotificationsScreen(),
      ),
      SidebarItem(
        id: 'expenses',
        icon: LucideIcons.walletCards,
        title: l10n.localeName == 'ar' ? 'المصروفات' : 'Expenses',
        screen: const ExpensesScreen(),
      ),
      SidebarItem(
        id: 'settings',
        icon: LucideIcons.settings,
        title: l10n.settings,
        screen: const SettingsScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMobileOrTablet = MediaQuery.of(context).size.width < 1000;

    return MultiBlocProvider(
      providers: [
        BlocProvider<StockCubit>.value(
          value: getIt<StockCubit>()..loadData(),
        ),
        BlocProvider<ProductCubit>.value(
          value: getIt<ProductCubit>()..getAllProducts(),
        ),
        BlocProvider<NotificationsCubit>.value(
          value: getIt<NotificationsCubit>()..loadData(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<NotificationsCubit, NotificationsStates>(
            listener: (context, state) {
              if (state is NotificationsError) {
                MotionSnackBarWarning(context, state.message);
              }
            },
          ),
          BlocListener<StockCubit, StockStates>(
            listener: (context, state) {
              if (state is StockSucssesState) {
                // Sync notifications when stock updates
                getIt<NotificationsCubit>().loadData();
              }
            },
          ),
        ],
        child: Directionality(
          textDirection:
              l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: isMobileOrTablet
                ? AppBar(
                    backgroundColor: AppColors.sidebarColor,
                    title: Text(sidebarItems[selectedIndex].title),
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(LucideIcons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    actions: _headerActions(context, compact: true),
                  )
                : null,
            drawer: isMobileOrTablet
                ? Drawer(
                    child: CustomSidebar(
                      items: sidebarItems,
                      selectedIndex: selectedIndex,
                      onItemSelected: (index) =>
                          _onSidebarSelected(context, index),
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
                    onItemSelected: (index) =>
                        _onSidebarSelected(context, index),
                    onToggleCollapse: () {
                      setState(() {
                        isSidebarCollapsed = !isSidebarCollapsed;
                      });
                    },
                  ),
                Expanded(
                  child: Container(
                    color: AppColors.backgroundColor,
                    child: Column(
                      children: [
                        if (!isMobileOrTablet)
                          _DesktopHeader(
                            pageTitle: sidebarItems[selectedIndex].title,
                            pageIcon: sidebarItems[selectedIndex].icon,
                            actions: _headerActions(context),
                          ),
                        Expanded(
                          child: ScreenHeaderScope(
                            showInPage: false,
                            child: sidebarItems[selectedIndex].screen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _headerActions(BuildContext context, {bool compact = false}) {
    return [
      _LanguageToggle(compact: compact),
      BlocBuilder<NotificationsCubit, NotificationsStates>(
        builder: (context, state) {
          final total = getIt<NotificationsCubit>().total;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: compact
                        ? Colors.white.withOpacity(.12)
                        : AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(13),
                    border: compact
                        ? null
                        : Border.all(color: AppColors.borderColor),
                  ),
                  child: IconButton(
                    tooltip: AppLocalizations.of(context).notifications,
                    padding: EdgeInsets.zero,
                    iconSize: 19,
                    icon: Icon(
                      LucideIcons.bell,
                      color: compact ? Colors.white : AppColors.textSecondary,
                    ),
                    onPressed: () => _openNotifications(context),
                  ),
                ),
                if (total > 0)
                  Positioned(
                    right: -2,
                    top: -3,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: AppColors.errorColor, shape: BoxShape.circle),
                      child: Text('$total',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      BlocBuilder<UserCubit, UserStates>(
        bloc: getIt<UserCubit>(),
        builder: (_, __) => _ProfileMenu(
          user: getIt<UserCubit>().currentUser,
          compact: compact,
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  void _openNotifications(BuildContext context) {
    final index = sidebarItems.indexWhere((item) => item.id == 'notifications');
    if (index != -1) _onSidebarSelected(context, index);
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
      MotionSnackBarWarning(
          context, AppLocalizations.of(context).screenUnavailable);
    }
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool compact;
  const _LanguageToggle({required this.compact});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).localeName == 'ar';
    final foreground = compact ? Colors.white : AppColors.textSecondary;

    return Tooltip(
      message: isArabic ? 'English' : 'العربية',
      child: InkWell(
        onTap: () => getIt<LocaleProvider>().toggleLocale(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 12),
          decoration: BoxDecoration(
            color: compact
                ? Colors.white.withOpacity(.12)
                : AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: compact ? null : Border.all(color: AppColors.borderColor),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.language, size: 18, color: foreground),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                isArabic ? 'EN' : 'ع',
                style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  final String pageTitle;
  final IconData pageIcon;
  final List<Widget> actions;
  const _DesktopHeader({
    required this.pageTitle,
    required this.pageIcon,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFFBFDFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border:
              const Border(bottom: BorderSide(color: AppColors.borderColor)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(pageIcon, size: 19, color: AppColors.secondaryColor),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              pageTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...actions,
        ]),
      );
}

class _ProfileMenu extends StatelessWidget {
  final User user;
  final bool compact;
  const _ProfileMenu({required this.user, required this.compact});

  @override
  Widget build(BuildContext context) {
    final name = TranslationHelper.translateUserName(context, user.name,
        username: user.username);
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return PopupMenuButton<String>(
      tooltip: name,
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == 'edit-profile') {
          showDialog<User>(
            context: context,
            builder: (_) => AddEditUserDialog(
              userToEdit: user,
              profileOnly: true,
            ),
          );
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Text(user.username,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedColor)),
              ]),
        ),
        PopupMenuItem<String>(
          value: 'edit-profile',
          child: Row(
            children: [
              const Icon(LucideIcons.pencil,
                  size: 18, color: AppColors.secondaryColor),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context).localeName == 'ar'
                    ? 'تعديل الملف الشخصي'
                    : 'Edit profile',
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: compact ? 4 : 10, vertical: 6),
        decoration: BoxDecoration(
          color: compact
              ? Colors.white.withOpacity(.12)
              : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          LocalImageView(
            path: user.imagePath,
            width: 32,
            height: 32,
            borderRadius: 16,
            fallback: Container(
              color: AppColors.secondaryColor,
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary))),
            const SizedBox(width: 4),
            const Icon(LucideIcons.chevronDown,
                size: 16, color: AppColors.mutedColor),
          ],
        ]),
      ),
    );
  }
}
