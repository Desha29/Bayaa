// ignore_for_file: deprecated_member_use
import 'package:bayaa_pos/core/functions/messege.dart';
import 'package:bayaa_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/core/localization/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_states.dart';

class SidebarItem {
  final String id;
  final IconData icon;
  final String title;
  final Widget screen;
  SidebarItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.screen,
  });
}

class CustomSidebar extends StatefulWidget {
  final List<SidebarItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const CustomSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  int _hoveredIndex = -1;

  List<dynamic> _getFilteredItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<dynamic> filtered = [];

    SidebarItem? findItem(String id) {
      for (var item in widget.items) {
        if (item.id == id) return item;
      }
      return null;
    }

    void addSection(String sectionTitle, List<String> itemIds) {
      final List<SidebarItem> sectionItems = [];
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

    addSection(l10n.homeSection, ['dashboard']);
    addSection(l10n.salesSection, ['sales', 'invoices']);
    addSection(
        l10n.stockSection, ['products', 'stock_alerts', 'stock_summary']);
    addSection(
      l10n.systemSection,
      ['expenses', 'reports', 'sessions', 'settings'],
    );

    return filtered;
  }

  // Kept temporarily for compatibility; the active language switch is in the
  // dashboard header and this sidebar widget no longer renders it.
  // ignore: unused_element
  Widget _buildLanguageToggle(bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          getIt<LocaleProvider>().toggleLocale();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 0 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isNarrow
              ? const Center(
                  child: Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: 184,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).localeName == 'ar'
                                ? 'English'
                                : 'العربية',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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

  Widget _buildLogoutButton(bool isNarrow) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () {
          handleLogout(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 0 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.errorColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isNarrow
              ? const Center(
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
                        const Icon(
                          LucideIcons.logOut,
                          color: AppColors.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).logout,
                            style: const TextStyle(
                              color: AppColors.errorColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.only(top: 16, bottom: 8, right: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNotificationsBadge({required bool mini}) {
    return BlocBuilder<NotificationsCubit, NotificationsStates>(
      builder: (context, state) {
        final total = getIt<NotificationsCubit>().total;
        if (total == 0) return const SizedBox.shrink();
        if (mini) {
          return Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(SidebarItem item, bool isNarrow) {
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
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 0 : 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
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
                        ? Colors.white.withOpacity(0.09)
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
                                ? Colors.white
                                : isHovered
                                    ? Colors.white
                                    : Colors.white70,
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
                              ? Colors.white
                              : isHovered
                                  ? Colors.white
                                  : Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isHovered
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.85),
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
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
                            decoration: const BoxDecoration(
                              color: Colors.white,
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
              gradient: const LinearGradient(
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
                ? const Center(
                    child: Icon(LucideIcons.plus, color: Colors.white, size: 20),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
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
                  child: BlocBuilder<SettingsCubit, SettingsStates>(
                    bloc: getIt<SettingsCubit>(),
                    builder: (context, state) {
                      final l10n = AppLocalizations.of(context);
                      final configuredName =
                          getIt<SettingsCubit>().currentStoreInfo?.name;
                      final isDefaultBrand = configuredName == null ||
                          configuredName.isEmpty ||
                          configuredName == 'Bayaa POS';

                      final name = isDefaultBrand
                          ? l10n.loginBrandName
                          : configuredName;
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: .3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.accentColor.withOpacity(0.4), width: 0.5),
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
                            ],
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
                        child: const Icon(
                          LucideIcons.chevronLeft,
                          color: Colors.white70,
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
    final width = widget.isCollapsed ? 72.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
                    return _buildMenuItem(item as SidebarItem, isNarrow);
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
