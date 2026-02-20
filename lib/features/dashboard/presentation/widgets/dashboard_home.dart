import 'package:crazy_phone_pos/core/components/logo.dart';
import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:crazy_phone_pos/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:crazy_phone_pos/core/components/app_logo.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart'
    show SettingsCubit;
import '../../../invoice/presentation/cubit/invoice_cubit.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../sessions/data/repositories/session_repository_impl.dart';
import 'dashboard_card.dart';
import 'recent_operations.dart';
import '../../../../core/session/session_manager.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome(
      {super.key, required this.onCardTap, required this.isManager});
  final void Function(String id) onCardTap;
  final bool isManager;

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final store = getIt<SettingsCubit>().currentStoreInfo;
  late List<Map<String, dynamic>> cards;

  @override
  void initState() {
    super.initState();
    // Load data for dashboard stats
    getIt<InvoiceCubit>().loadSales();
    getIt<ProductCubit>().getAllCategories();

    // Initialize cards with placeholders, then update with data
    _initCards();

    // Fetch session count and update
    if (widget.isManager) {
      _loadSessionCount();
    }

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

  void _initCards() {
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
      {
        "id": "stock_summary",
        "icon": LucideIcons.layers,
        "title": "ملخص المخزون",
        "subtitle": "تصنيفات المخزون",
        "color": Colors.teal,
      },
      if (widget.isManager) ...[
        {
          "id": "reports",
          "icon": LucideIcons.pieChart,
          "title": "الإحصائيات",
          "subtitle": "تحليلات النظام",
          "color": AppColors.primaryColor,
        },
        {
          "id": "sessions",
          "icon": LucideIcons.history,
          "title": "الايام",
          "subtitle": "سجل الأيام المغلقة",
          "color": Colors.orange,
        },
      ] else ...[
        {
          "id": "settings",
          "icon": LucideIcons.settings,
          "title": "الإعدادات",
          "subtitle": "إدارة إعدادات النظام",
          "color": Colors.blueGrey,
        },
      ],
      if (!widget.isManager)
        {
          "id": "notifications",
          "icon": LucideIcons.bell,
          "title": "التنبيهات",
          "subtitle": "الإشعارات والتنبيهات",
          "color": AppColors.darkGold,
        },
    ];
  }

  Future<void> _loadSessionCount() async {
    try {
      final repo = getIt<SessionRepositoryImpl>();
      final count = await repo.getSessionsCount();

      if (mounted) {
        setState(() {
          final index = cards.indexWhere((c) => c['id'] == 'sessions');
          if (index != -1) {
            cards[index]['subtitle'] = '$count يوم مغلق';
          }
        });
      }
    } catch (e) {
      print('Failed to load session count: $e');
    }
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
        int crossAxisCount = 2;
        double aspectRatio = 1.4;

        if (constraints.maxWidth < 800) {
          crossAxisCount = 1;
          aspectRatio = 1.8;
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 2;
          aspectRatio = 1.3;
        } else {
          crossAxisCount = 3;
          aspectRatio = 1.4;
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: "لوحة التحكم",
                subtitle:
                    "مرحباً بك في نظام ${store?.name ?? "Bayaa"} لإدارة نقاط البيع",
                icon: LucideIcons.layoutDashboard,
                titleColor: AppColors.textPrimary,
                iconColor: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),
              // Stale session warning banner
              Builder(
                builder: (context) {
                  final manager = getIt<SessionManager>();
                  if (!manager.isSessionStale) return const SizedBox.shrink();
                  final age = manager.sessionAge!;
                  final hours = age.inHours;
                  final days = hours ~/ 24;
                  final remainingHours = hours % 24;
                  final ageText = days > 0
                      ? '$days يوم و $remainingHours ساعة'
                      : '$hours ساعة';
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertTriangle,
                            color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'اليوم الحالي مفتوح منذ $ageText — يُنصح بإغلاقه وفتح يوم جديد',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid - Takes 60% width
                    Expanded(
                      flex: 6,
                      child: GridView.count(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
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
                    const SizedBox(width: 16),
                    // Recent Operations - Takes 30% width
                    const Expanded(
                      flex: 3,
                      child: RecentOperations(),
                    ),
                  ],
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
