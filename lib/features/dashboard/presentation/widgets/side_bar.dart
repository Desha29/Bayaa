// ignore_for_file: deprecated_member_use
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';

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
    _widthAnimation = Tween<double>(
      begin: 240,
      end: 70,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.isCollapsed) _controller.forward();
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
        final w = _widthAnimation.value.clamp(56.0, 320.0);
        final compact = w < 100;

        return Container(
          width: w,
          decoration: BoxDecoration(
            color: AppColors.primaryForeground,
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
              const SizedBox(height: 20),
              // Responsive header with logo and labels
              SizedBox(
                height: 96,
                child: Center(
                  child: _SidebarHeader(compact: compact, maxW: w),
                ),
              ),
              const SizedBox(height: 12),

              // Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = index == widget.selectedIndex;
                    final isHovered = index == _hoveredIndex;

                    final bgColor = isSelected
                        ? AppColors.primaryColor.withOpacity(0.95)
                        : isHovered
                            ? AppColors.primaryColor.withOpacity(0.08)
                            : Colors.transparent;

                    final fgIcon = isSelected
                        ? AppColors.primaryForeground
                        : AppColors.mutedColor;

                    final titleStyle = TextStyle(
                      fontSize: 15,
                      color: isSelected
                          ? AppColors.primaryForeground
                          : AppColors.secondaryColor,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    );

                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = -1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          dense: true,
                          horizontalTitleGap: 12,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          leading: Icon(item.icon, size: 22, color: fgIcon),
                          title: w > 100
                              ? Row(
                                  children: [
                                    // Fitted text to avoid overflow at tight widths
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          item.title,
                                          style: titleStyle,
                                        ),
                                      ),
                                    ),
                                  ],
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
                dense: true,
                leading: const Icon(
                  LucideIcons.logOut,
                  color: AppColors.errorColor,
                  size: 22,
                ),
                title: w > 100
                    ? const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          "تسجيل الخروج",
                          style: TextStyle(
                            color: AppColors.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  handleLogout(context);
                },
              ),
              const SizedBox(height: 12),
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

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.compact, required this.maxW});

  final bool compact;
  final double maxW;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 20.0 : 30.0; // slightly smaller

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // important: shrink to fit
      children: [
        Flexible(
          child: FittedBox(
            child: SizedBox(
              height: radius * 3,
              width: radius * 3,
              child: ClipOval(
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        if (!compact) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Crazy Phone',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryColor,
                          fontSize: 13,
                          height: 1.2, // tighter line-height
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
      ],
    );
  }
}
