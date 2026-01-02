import 'package:crazy_phone_pos/core/components/logo.dart';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:crazy_phone_pos/core/components/app_logo.dart';
import 'dashboard_card.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key, required this.onCardTap, required this.isManager});
  final void Function(String id) onCardTap;
  final bool isManager;

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  late List<Map<String, dynamic>> cards;

  @override
  void initState() {
    super.initState();
    cards = [
    {
      "id": "sales",
      "icon": LucideIcons.shoppingCart,
      "title": "المبيعات",
      "subtitle": "إدارة عمليات البيع",
      "color": AppColors.primaryColor,
    },
    {
      "id": "invoices",
      "icon": LucideIcons.fileText,
      "title": "الفواتير",
      "subtitle": "إدارة الفواتير",
      "color": AppColors.accentGold,
    },
    {
      "id": "products",
      "icon": LucideIcons.package,
      "title": "المنتجات",
      "subtitle": "إدارة المخزون",
      "color": AppColors.successColor,
    },
    {
      "id": "stock_alerts",
      "icon": LucideIcons.alertTriangle,
      "title": "المنتجات الناقصة",
      "subtitle": "تنبيهات المخزون",
      "color": AppColors.warningColor,
    },
    if (widget.isManager)
    {
      "id": "reports",
      "icon": LucideIcons.barChart2,
      "title": "التحديلات و التقارير",
      "subtitle": "ادارة تقارير النظام",
      "color": AppColors.primaryColor,
    }
    else 
    {
      "id": "settings",
      "icon": LucideIcons.settings,
      "title": "الإعدادات",
      "subtitle": "إدارة إعدادات النظام",
      "color": Colors.blueGrey,
    },
    {
      "id": "notifications",
      "icon": LucideIcons.bell,
      "title": "التنبيهات",
      "subtitle": "الإشعارات والتنبيهات",
      "color": AppColors.darkGold,
    },
  ];
    _controllers = List.generate(
      cards.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _animations = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutBack))
        .toList();

    Future.forEach(List.generate(cards.length, (i) => i), (i) async {
      await Future.delayed(Duration(milliseconds: i * 150));
      if (mounted && i < _controllers.length) {
        _controllers[i].forward();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        double aspectRatio = 1.8;

        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
          aspectRatio = 1.6;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2;
          aspectRatio = 1.1;
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: "لوحة التحكم",
                subtitle: "مرحباً بك في نظام Bayaa لإدارة نقاط البيع",
                icon: LucideIcons.layoutDashboard,
                titleColor: AppColors.kDarkChip,
                iconColor: AppColors.primaryColor,
              ),
              Align(
                alignment: Alignment.center,
                child: Shimmer(
                  enabled: true,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: AppColors.surfaceColor,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(80),
                      child: const AppLogo(width: 160, height: 160, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 4, 
                  crossAxisSpacing: 8, 
                  childAspectRatio: aspectRatio,
                  children: List.generate(cards.length, (index) {
                    final card = cards[index];
                    return _buildAnimatedCard(
                      index: index,
                      child: DashboardCard(
                        icon: card["icon"],
                        title: card["title"],
                        subtitle: card["subtitle"],
                        color: card["color"],
                        onTap: () => widget.onCardTap(card["id"]),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return ScaleTransition(
      scale: _animations[index],
      child: FadeTransition(opacity: _animations[index], child: child),
    );
  }
}
