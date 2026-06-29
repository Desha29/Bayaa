// ignore_for_file: deprecated_member_use
import 'package:bayaa_pos/core/functions/messege.dart';
import 'package:bayaa_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/components/app_logo.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_states.dart';
import '../../../auth/presentation/cubit/user_cubit.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/data/services/persistence_initializer.dart';

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

  List<dynamic> get _filteredItems {
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

    addSection('الرئيسية', ['dashboard']);
    addSection('المبيعات والفواتير', ['sales', 'invoices']);
    addSection('المخازن والمنتجات', ['products', 'stock_alerts', 'stock_summary']);
    addSection('النظام والتقارير', ['reports', 'sessions', 'notifications', 'settings']);

    return filtered;
  }

  Widget _buildUserInfo(bool isNarrow) {
    final user = getIt<UserCubit>().currentUser;
    final firstLetter = user.name.isNotEmpty ? user.name.substring(0, 1) : '?';
    final roleName = user.userType == UserType.manager ? 'مدير النظام' : 'كاشير';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(isNarrow ? 8 : 12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isNarrow
          ? Center(
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: 192, // 240 max width - 24 margin - 24 padding
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            roleName,
                            style: const TextStyle(
                              color: AppColors.mutedColor,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildConnectivityStatus(),
                              if (PersistenceInitializer.persistenceManager?.config.appMode == 'debug') ...[
                                const SizedBox(width: 4),
                                _buildDebugBadge(),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildConnectivityStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'متصل',
            style: TextStyle(
              color: Colors.green,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'تجريبي',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
                        const Expanded(
                          child: Text(
                            'تسجيل الخروج',
                            style: TextStyle(
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
          color: AppColors.mutedColor.withOpacity(0.7),
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
      padding: const EdgeInsets.only(bottom: 4),
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
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 0 : 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.15)
                    : isHovered
                        ? AppColors.primaryColor.withOpacity(0.05)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 1,
                      )
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
                                ? AppColors.primaryColor
                                : isHovered
                                    ? AppColors.textPrimary
                                    : AppColors.mutedColor,
                            size: 22,
                          ),
                          if (item.title == 'التنبيهات')
                            Positioned(
                              right: -4,
                              top: -4,
                              child: _buildNotificationsBadge(mini: true),
                            ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                        width: 184, // 240 width - 24 margin - 32 internal padding
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : isHovered
                                      ? AppColors.textPrimary
                                      : AppColors.mutedColor,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : isHovered
                                          ? AppColors.textPrimary
                                          : AppColors.secondaryColor,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (item.title == 'التنبيهات')
                              _buildNotificationsBadge(mini: false)
                            else if (isSelected)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isNarrow) {
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 16),
      child: isNarrow
          ? Center(
              child: InkWell(
                onTap: widget.onToggleCollapse,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    LucideIcons.menu,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: 208, // 240 width - 32 padding
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const AppLogo(
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<SettingsCubit, SettingsStates>(
                            bloc: getIt<SettingsCubit>(),
                            builder: (context, state) {
                              final name = getIt<SettingsCubit>().currentStoreInfo?.name ?? 'Bayaa';
                              return Text(
                                name.isNotEmpty ? name : 'Bayaa',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              );
                            },
                          ),
                          const Text(
                            "نظام إدارة المبيعات",
                            style: TextStyle(
                              color: AppColors.mutedColor,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (widget.onToggleCollapse != null)
                      InkWell(
                        onTap: widget.onToggleCollapse,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            LucideIcons.chevronLeft,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
        color: AppColors.primaryForeground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 140;

          return Column(
            children: [
              _buildHeader(isNarrow),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    if (item is String) {
                      return _buildSectionHeader(item, isNarrow);
                    }
                    return _buildMenuItem(item as SidebarItem, isNarrow);
                  },
                ),
              ),
              _buildUserInfo(isNarrow),
              _buildLogoutButton(isNarrow),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
