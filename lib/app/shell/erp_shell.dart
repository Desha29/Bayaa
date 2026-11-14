import 'package:bayaa_pos/app/navigation/workspace_search_dialog.dart';
import 'package:bayaa_pos/shared/widgets/loading/skeleton.dart';
import 'package:bayaa_pos/app/navigation/erp_destination.dart';
import 'package:bayaa_pos/app/navigation/erp_destinations.dart';
import 'package:bayaa_pos/app/shell/widgets/erp_header.dart';
import 'package:bayaa_pos/features/auth/presentation/models/user_view_data.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notification_cubit.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notification_state.dart';
import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_alerts_cubit.dart';
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
import 'package:bayaa_pos/features/products/presentation/controllers/product_cubit.dart';

import 'package:bayaa_pos/features/inventory/presentation/controllers/stock_alerts_state.dart';

import 'package:bayaa_pos/app/shell/widgets/erp_sidebar.dart';
import 'package:bayaa_pos/app/shell/widgets/branch_context_bar.dart';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:bayaa_pos/shared/layout/adaptive_workspace_viewport.dart';

class ErpShell extends StatefulWidget {
  const ErpShell({super.key});

  @override
  State<ErpShell> createState() => _ErpShellState();
}

class _ErpShellState extends State<ErpShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  bool isSidebarCollapsed = false;
  final _branchScope = BranchPreviewController.instance;
  String _lastBranch = 'all';

  @override
  void initState() {
    super.initState();
    _lastBranch = _branchScope.activeId;
    _branchScope.addListener(_onScopeChanged);
  }

  void _onScopeChanged() {
    if (_lastBranch != _branchScope.activeId) {
      _lastBranch = _branchScope.activeId;
      final products = getIt<ProductCubit>();
      products.selectedCategory = '*';
      products.selectedAvailability = '*';
      products.currentSearchQuery = '';
      getIt<SettingsCubit>().loadStoreInfo();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _branchScope.removeListener(_onScopeChanged);
    super.dispose();
  }

  UserViewData get curUser => getIt<UserCubit>().currentUser;

  List<ErpDestination> get sidebarItems =>
      buildErpDestinations(context, onCardTap: handleCardTap);

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isMobileOrTablet = MediaQuery.of(context).size.width < 1024;

    return MultiBlocProvider(
      providers: [
        BlocProvider<StockAlertsCubit>.value(
          value: getIt<StockAlertsCubit>()..loadData(),
        ),
        BlocProvider<ProductCubit>.value(
          value: getIt<ProductCubit>()..getAllProducts(),
        ),
        BlocProvider<NotificationCubit>.value(
          value: getIt<NotificationCubit>()..loadData(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<NotificationCubit, NotificationState>(
            listener: (context, state) {
              if (state is NotificationsError) {
                showWarningMessage(context, state.message);
              }
            },
          ),
          BlocListener<StockAlertsCubit, StockAlertsState>(
            listener: (context, state) {
              if (state is StockLoadedState) {
                // Sync notifications when stock updates
                getIt<NotificationCubit>().loadData();
              }
            },
          ),
        ],
        child: Directionality(
          textDirection:
              l10n.localeName == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: isMobileOrTablet
                ? AppBar(
                    backgroundColor: AppColors.sidebarColor,
                    foregroundColor: AppColors.sidebarForeground,
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
                            onSearch: () => _openWorkspaceSearch(context),
                          ),
                        const BranchContextBar(),
                        Expanded(
                          child: AdaptiveWorkspaceViewport(
                              child: ScreenHeaderScope(
                            showInPage: false,
                            child: SkeletonReveal(
                                key: ValueKey(
                                    '${_branchScope.activeId}:${sidebarItems[selectedIndex].id}'),
                                child: !_branchScope.moduleVisible(
                                        sidebarItems[selectedIndex].id)
                                    ? BranchDataGate(
                                        module: sidebarItems[selectedIndex].id)
                                    : sidebarItems[selectedIndex].screen),
                          )),
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
      if (compact)
        IconButton(
            tooltip: AppLocalizations.of(context).localeName == 'ar'
                ? 'بحث'
                : 'Search',
            icon: Icon(Icons.search, color: AppColors.sidebarForeground),
            onPressed: () => _openWorkspaceSearch(context)),
      if (!compact && MediaQuery.sizeOf(context).width >= 1440)
        const DateTimeBadge(),
      LanguageToggle(compact: compact),
      BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final total = getIt<NotificationCubit>().total;
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
                      color: compact
                          ? AppColors.sidebarForeground
                          : AppColors.textSecondary,
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
                      decoration: BoxDecoration(
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
          compact: compact || MediaQuery.sizeOf(context).width < 1280,
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  Future<void> _openWorkspaceSearch(BuildContext context) async {
    final selected = await showDialog<String>(
        context: context,
        builder: (_) => WorkspaceSearchDialog(destinations: sidebarItems));
    if (selected == null || !mounted || !context.mounted) return;
    final index = sidebarItems.indexWhere((item) => item.id == selected);
    if (index >= 0) _onSidebarSelected(context, index);
  }

  void _openNotifications(BuildContext context) {
    final index = sidebarItems.indexWhere((item) => item.id == 'notifications');
    if (index != -1) _onSidebarSelected(context, index);
  }

  void _onSidebarSelected(BuildContext context, int index) {
    setState(() => selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  /// Handles tap on a card in the dashboard screen.
  void handleCardTap(String id) {
    final index = sidebarItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _onSidebarSelected(context, index);
    } else {
      showWarningMessage(
          context, AppLocalizations.of(context).screenUnavailable);
    }
  }
}
