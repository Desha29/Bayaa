# Shared Flutter layouts
### lib/app/shell/erp_shell.dart

```dart
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import 'package:bayaa_pos/app/navigation/erp_destination.dart';
import 'package:bayaa_pos/app/navigation/erp_destinations.dart';
import 'package:bayaa_pos/app/shell/widgets/erp_header.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notifications_cubit.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notifications_state.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_cubit.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/screen_header.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/shared/feedback/app_messages.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_cubit.dart';
import 'package:bayaa_pos/features/auth/presentation/controllers/user_state.dart';
import 'package:bayaa_pos/features/invoices/presentation/controllers/invoice_cubit.dart';
import 'package:bayaa_pos/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:bayaa_pos/features/products/presentation/controllers/product_cubit.dart';
import 'package:bayaa_pos/features/products/presentation/screens/products_screen.dart';
import 'package:bayaa_pos/preview/sources/sample_invoice_source.dart';

import 'package:bayaa_pos/features/pos/presentation/screens/pos_screen.dart';
import 'package:bayaa_pos/features/settings/presentation/screens/settings_screen.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_state.dart';
import 'package:bayaa_pos/features/inventory/presentation/screens/stock_screen.dart';
import 'package:bayaa_pos/features/invoices/presentation/screens/invoices_screen.dart';

import 'package:bayaa_pos/features/sessions/presentation/screens/sessions_dashboard_screen.dart';
import 'package:bayaa_pos/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:bayaa_pos/features/analytics/presentation/controllers/analytics_cubit.dart';
import 'package:bayaa_pos/preview/sources/sample_analytics_source.dart';

import 'package:bayaa_pos/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:bayaa_pos/app/shell/widgets/erp_sidebar.dart';
import 'package:bayaa_pos/features/stock_summary/presentation/screens/stock_summary_screen.dart';
import 'package:bayaa_pos/features/stock_summary/presentation/controllers/stock_summary_cubit.dart';
import 'package:bayaa_pos/features/expenses/presentation/screens/expenses_screen.dart';

class ErpShell extends StatefulWidget {
  const ErpShell({super.key});

  @override
  State<ErpShell> createState() => _ErpShellState();
}

class _ErpShellState extends State<ErpShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  bool isSidebarCollapsed = false;



  UserViewData get curUser => getIt<UserCubit>().currentUser;

  List<ErpDestination> get sidebarItems => buildErpDestinations(context, onCardTap: handleCardTap);



  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isMobileOrTablet = MediaQuery.of(context).size.width < 1024;

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
          BlocListener<NotificationsCubit, NotificationState>(
            listener: (context, state) {
              if (state is NotificationsError) {
                MotionSnackBarWarning(context, state.message);
              }
            },
          ),
          BlocListener<StockCubit, StockState>(
            listener: (context, state) {
              if (state is StockLoadedState) {
                // Sync notifications when stock updates
                getIt<NotificationsCubit>().loadData();
              }
            },
          ),
        ],
        child: Directionality(
          textDirection:
              l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(key: _scaffoldKey,
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
                    child: ErpSidebar(
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
                  ErpSidebar(
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
                          ErpDesktopHeader(
                            pageTitle: sidebarItems[selectedIndex].title,
                            pageIcon: sidebarItems[selectedIndex].icon,
                            actions: _headerActions(context),
                          ),
                        Expanded(
                          child: ScreenHeaderScope(
                            showInPage: false,
                            child: SkeletonReveal(key: ValueKey(sidebarItems[selectedIndex].id), child: sidebarItems[selectedIndex].screen),
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
      if (!compact) const DateTimeBadge(),
      LanguageToggle(compact: compact),
      BlocBuilder<NotificationsCubit, NotificationState>(
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
      BlocBuilder<UserCubit, UserState>(
        bloc: getIt<UserCubit>(),
        builder: (_, __) => ProfileMenu(
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
    setState(() => selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) _scaffoldKey.currentState?.closeDrawer();
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

```
### lib/shared/layout/layout_tokens.dart

```dart
import 'package:flutter/material.dart';

/// All breakpoints are based on available content width, across platforms.
abstract final class LayoutTokens {
  static const compact = 600.0;
  static const medium = 1024.0;
  static const wide = 1440.0;
  static const contentMaxWidth = 1800.0;
  static const pageGap = 20.0;
  static const cardRadius = 16.0;

  static EdgeInsets pagePadding(double width) => EdgeInsets.all(
      width < compact ? 12 : width < medium ? 20 : 24);
  static int columns(double width, {double minWidth = 260, int max = 4}) =>
      (width / minWidth).floor().clamp(1, max);
}

class AdaptiveColumns extends StatelessWidget {
  const AdaptiveColumns({super.key, required this.children,
    this.minWidth = 260, this.maxColumns = 4, this.spacing = 16});
  final List<Widget> children;
  final double minWidth;
  final int maxColumns;
  final double spacing;
  @override
  Widget build(BuildContext context) => Builder(builder: (context) { Theme.of(context); return LayoutBuilder(builder: (context, size) {
    final count = LayoutTokens.columns(size.maxWidth, minWidth: minWidth, max: maxColumns);
    final width = (size.maxWidth - (count - 1) * spacing) / count;
    return Wrap(spacing: spacing, runSpacing: spacing,
      children: children.map((child) => SizedBox(width: width, child: child)).toList());
  }); });
}

```
