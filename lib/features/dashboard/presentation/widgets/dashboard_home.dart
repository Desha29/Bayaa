import 'package:crazy_phone_pos/core/components/logo.dart';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dashboard_card.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key, required this.onCardTap});

  final void Function(int index) onCardTap;

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  final List<Map<String, dynamic>> cards = [
    {
      "icon": LucideIcons.bell,
      "title": "التنبيهات",
      "subtitle": "الإشعارات والتنبيهات",
      "color": Colors.blue,
    },
    {
      "icon": LucideIcons.alertTriangle,
      "title": "المنتجات الناقصة",
      "subtitle": "تنبيهات المخزون",
      "color": Colors.orange,
    },
    {
      "icon": LucideIcons.package,
      "title": "المنتجات",
      "subtitle": "إدارة المخزون",
      "color": Colors.green,
    },
    {
      "icon": LucideIcons.shoppingCart,
      "title": "المبيعات",
      "subtitle": "إدارة عمليات البيع",
      "color": Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();

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

    Future.forEach<int>(List.generate(cards.length, (i) => i), (i) async {
      await Future.delayed(Duration(milliseconds: i * 150));
      _controllers[i].forward();
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
        int crossAxisCount = 4;
        double aspectRatio = 1.2;

        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
          aspectRatio = 1.8;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2;
          aspectRatio = 1.6;
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: "لوحة التحكم",
                subtitle: "مرحباً بك في نظام Crazy Phone لإدارة نقاط البيع",
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: Shimmer(
                  enabled: true,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
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
                        onTap: () => widget.onCardTap(_getTargetScreenIndex(index)),
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

  int _getTargetScreenIndex(int cardIndex) {
    switch (cardIndex) {
      case 0:
        return 4; // التنبيهات
      case 1:
        return 3; // المنتجات الناقصة
      case 2:
        return 2; // المنتجات
      case 3:
        return 1; // المبيعات
      default:
        return 0;
    }
  }
}
