// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

// Sidebar Item Model
class SidebarItem {
  final IconData icon;
  final String title;
  final Widget screen;

  SidebarItem({required this.icon, required this.title, required this.screen});
}

class CustomSidebar extends StatefulWidget {
  final List<SidebarItem> items;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;

  const CustomSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _widthAnimation =
        Tween<double>(begin: 240, end: 70).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isCollapsed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CustomSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: AppColors.kCardBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Logo
              const Icon(
                LucideIcons.smartphone,
                size: 48,
                color: AppColors.primaryColor,
              ),
              if (_widthAnimation.value > 100) ...[
                const SizedBox(height: 10),
                const Text(
                  "Crazy Phone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 0.5,
                    color: AppColors.secondaryColor,
                  ),
                ),
                const Text(
                  "نظام نقاط البيع",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedColor,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Sidebar items
              Expanded(
                child: ListView.builder(
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = index == widget.selectedIndex;
                    final isHovered = index == _hoveredIndex;

                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = -1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor.withOpacity(0.95)
                              : isHovered
                                  ? AppColors.primaryColor.withOpacity(0.08)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.primaryForeground
                                : AppColors.mutedColor,
                          ),
                          title: _widthAnimation.value > 100
                              ? Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? AppColors.primaryForeground
                                        : AppColors.secondaryColor,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                )
                              : null,
                          onTap: () => widget.onItemSelected(index),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Divider(
                color: AppColors.borderColor,
                height: 1,
                thickness: 0.8,
              ),
              ListTile(
                leading: const Icon(
                  LucideIcons.logOut,
                  color: AppColors.errorColor,
                  size: 22,
                ),
                title: _widthAnimation.value > 100
                    ? const Text(
                        "تسجيل الخروج",
                        style: TextStyle(
                          color: AppColors.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
                onTap: () {
                  // TODO: Logout Logic
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
