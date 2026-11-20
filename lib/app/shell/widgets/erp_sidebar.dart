import 'package:bayaa_pos/app/navigation/erp_destination.dart';
// ignore_for_file: deprecated_member_use
import 'package:bayaa_pos/shared/feedback/app_messages.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notification_state.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/app/bootstrap/service_locator.dart';
import 'package:bayaa_pos/features/notifications/presentation/controllers/notification_cubit.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_cubit.dart';
import 'package:bayaa_pos/features/settings/presentation/controllers/settings_state.dart';

class ErpSidebar extends StatefulWidget {
  final List<ErpDestination> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const ErpSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  State<ErpSidebar> createState() => _ErpSidebarState();
}

class _ErpSidebarState extends State<ErpSidebar> {
  int _hoveredIndex = -1;

  List<dynamic> _getFilteredItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<dynamic> filtered = [];

    ErpDestination? findItem(String id) {
      for (var item in widget.items) {
        if (item.id == id) return item;
      }
      return null;
    }

    void addSection(String sectionTitle, List<String> itemIds) {
      final List<ErpDestination> sectionItems = [];
      for (var id in itemIds) {
        final item = findItem(id);
        if (item != null) {
          sectionItems.add(item);
        }
      }
      if (sectionItems.isNotEmpty) {
        filtered.add(sectionTitle);
        filtered.addAll(sectionItems);
      }
    }

    final ar = l10n.localeName == 'ar';
    addSection(l10n.homeSection, ['dashboard']);
    addSection(l10n.salesSection, ['sales', 'invoices', 'customers']);
    addSection(l10n.stockSection,
        ['products', 'stock_summary', 'stock_alerts', 'warehouses']);
    addSection(ar ? 'المشتريات والموردون' : 'Purchases & suppliers',
        ['purchases', 'purchase_returns', 'suppliers']);
    addSection(ar ? 'المالية والتقارير' : 'Finance & reports',
        ['finance', 'expenses', 'reports']);
    addSection(l10n.systemSection, ['notifications', 'settings']);

    return filtered;
  }

  Widget _buildLogoutButton(bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          handleLogout(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 0 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.errorColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isNarrow
              ? Center(
                  child: Icon(
                    LucideIcons.logOut,
                    color: AppColors.errorColor,
                    size: 20,
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: 184, // 240 width - 24 padding - 32 internal padding
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.logOut,
                          color: AppColors.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).logout,
                            style: TextStyle(
                              color: AppColors.errorColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isNarrow) {
    if (isNarrow) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(
          color: AppColors.borderColor.withOpacity(0.5),
          indent: 8,
          endIndent: 8,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 12, bottom: 6, start: 16),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.sidebarForeground.withValues(alpha: .54),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNotificationsBadge({required bool mini}) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final total = getIt<NotificationCubit>().total;
        if (total == 0) return const SizedBox.shrink();
        if (mini) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.errorColor,
              shape: BoxShape.circle,
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.errorColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$total',
            style: TextStyle(
              color: AppColors.sidebarForeground,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(ErpDestination item, bool isNarrow) {
    final originalIndex = widget.items.indexOf(item);
    final isSelected = widget.selectedIndex == originalIndex;
    final isHovered = _hoveredIndex == originalIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = originalIndex),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: Tooltip(
          message: isNarrow ? item.title : '',
          preferBelow: false,
          waitDuration: const Duration(milliseconds: 400),
          child: GestureDetector(
            onTap: () => widget.onItemSelected(originalIndex),
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 0 : 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          AppColors.secondaryColor,
                          AppColors.primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : isHovered
                        ? AppColors.sidebarForeground.withOpacity(0.09)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondaryColor.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: isNarrow
                  ? Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected
                                ? AppColors.primaryForeground
                                : isHovered
                                    ? AppColors.sidebarForeground
                                    : AppColors.sidebarForeground
                                        .withValues(alpha: .7),
                            size: 21,
                          ),
                          if (item.id == 'notifications')
                            Positioned(
                              right: -4,
                              top: -4,
                              child: _buildNotificationsBadge(mini: true),
                            ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        if (isSelected)
                          Container(
                            width: 3.5,
                            height: 18,
                            margin: const EdgeInsetsDirectional.only(end: 10),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        Icon(
                          item.icon,
                          color: isSelected
                              ? AppColors.primaryForeground
                              : isHovered
                                  ? AppColors.sidebarForeground
                                  : AppColors.sidebarForeground
                                      .withValues(alpha: .7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryForeground
                                  : isHovered
                                      ? AppColors.sidebarForeground
                                      : AppColors.sidebarForeground
                                          .withOpacity(0.85),
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (item.id == 'notifications')
                          _buildNotificationsBadge(mini: false)
                        else if (isSelected)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(bool isNarrow) {
    final l10n = AppLocalizations.of(context);
    final salesIndex = widget.items.indexWhere((it) => it.id == 'sales');
    if (salesIndex == -1) return const SizedBox.shrink();

    final label = l10n.localeName == 'ar' ? 'بيع جديد' : 'New Sale';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 8 : 12,
        vertical: 8,
      ),
      child: Tooltip(
        message: isNarrow ? label : '',
        child: InkWell(
          onTap: () => widget.onItemSelected(salesIndex),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentColor,
                  AppColors.darkGold,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentColor.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isNarrow
                ? Center(
                    child: Icon(LucideIcons.plus,
                        color: AppColors.accentForeground, size: 20),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.plus,
                          color: AppColors.accentForeground, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.accentForeground,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isNarrow) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 14),
      child: isNarrow
          ? Center(
              child: InkWell(
                onTap: widget.onToggleCollapse,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/Icon_app.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/Icon_app.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BlocBuilder<SettingsCubit, SettingsState>(
                    bloc: getIt<SettingsCubit>(),
                    builder: (context, state) {
                      final l10n = AppLocalizations.of(context);
                      final configuredName =
                          getIt<SettingsCubit>().currentStoreInfo?.name;
                      final isDefaultBrand = configuredName == null ||
                          configuredName.isEmpty ||
                          configuredName == 'Bayaa POS';

                      final name =
                          isDefaultBrand ? l10n.loginBrandName : configuredName;
                      final displayName = l10n.localeName == 'en'
                          ? name.replaceAll(
                              RegExp(r'\s+POS$', caseSensitive: false),
                              '',
                            )
                          : name;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              color: AppColors.sidebarForeground,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: AppColors.accentColor
                                        .withOpacity(0.4),
                                    width: 0.5),
                              ),
                              child: Text(
                                'ERP SaaS',
                                style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (widget.onToggleCollapse != null)
                  InkWell(
                    onTap: widget.onToggleCollapse,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Transform.flip(
                        flipX: AppLocalizations.of(context).localeName == 'ar',
                        child: Icon(
                          LucideIcons.chevronLeft,
                          color:
                              AppColors.sidebarForeground.withValues(alpha: .7),
                          size: 19,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final width = widget.isCollapsed ? 72.0 : 240.0;

    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: AppColors.sidebarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 140;
          final filteredItems = _getFilteredItems(context);

          return Column(
            children: [
              _buildHeader(isNarrow),
              const SizedBox(height: 2),
              _buildQuickActionButton(isNarrow),
              const SizedBox(height: 2),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    if (item is String) {
                      return _buildSectionHeader(item, isNarrow);
                    }
                    return _buildMenuItem(item as ErpDestination, isNarrow);
                  },
                ),
              ),
              _buildLogoutButton(isNarrow),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
