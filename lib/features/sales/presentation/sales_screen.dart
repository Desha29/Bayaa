import 'package:flutter/material.dart';
import '../../../core/components/screen_header.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/recent_sales.dart';

import 'widgets/barcode_scan_card.dart';
import 'widgets/cart_section.dart';
import 'widgets/total_section_card.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Dummy data
  final List<Map<String, dynamic>> dummyCartItems = [
    {
      'id': 'P001',
      'name': 'آيفون 14 برو',
      'price': 4500.0,
      'qty': 2,
      'date': DateTime(2025, 10, 15),
    },
    {
      'id': 'P002',
      'name': 'سامسونج جالاكسي S23',
      'price': 3200.0,
      'qty': 1,
      'date': DateTime(2025, 10, 14),
    },
    {
      'id': 'P003',
      'name': 'ايربودز برو',
      'price': 1200.0,
      'qty': 3,
      'date': DateTime(2025, 10, 16),
    },
  ];

  final List<Map<String, dynamic>> dummyRecentSales = [
    {'total': 8500.0, 'items': 4, 'date': DateTime(2025, 10, 15, 14, 30)},
    {'total': 12300.0, 'items': 6, 'date': DateTime(2025, 10, 15, 11, 15)},
    {'total': 5600.0, 'items': 2, 'date': DateTime(2025, 10, 14, 16, 45)},
    {'total': 9800.0, 'items': 5, 'date': DateTime(2025, 10, 14, 9, 20)},
    {'total': 9800.0, 'items': 5, 'date': DateTime(2025, 10, 14, 9, 20)},
    {'total': 9800.0, 'items': 5, 'date': DateTime(2025, 10, 14, 9, 20)},
    {'total': 9800.0, 'items': 5, 'date': DateTime(2025, 10, 14, 9, 20)},
  ];

  double get totalAmount {
    return dummyCartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['qty']),
    );
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1200;
            final isTablet =
                constraints.maxWidth >= 768 && constraints.maxWidth <= 1200;

            return Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
              child: (isDesktop || isTablet)
                  ? _buildDesktopTabletLayout(isDesktop)
                  : _buildMobileLayout(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopTabletLayout(bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isDesktop ? 7 : 6,
          child: SingleChildScrollView(
            child: _buildMainContent(),
          ),
        ),
        SizedBox(width: isDesktop ? 32 : 24),
        Expanded(
          flex: isDesktop ? 3 : 4,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RecentSalesSection(recentSales: dummyRecentSales),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMainContent(),
          const SizedBox(height: 24),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: RecentSalesSection(recentSales: dummyRecentSales),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenHeader(
          title: 'شاشة المبيعات',
          subtitle: 'إدارة عمليات البيع والفواتير',
          fontSize: 32,
          icon: Icons.point_of_sale,
          iconColor: AppColors.primaryColor,
          titleColor: AppColors.kDarkChip,
        ),
        const SizedBox(height: 24),
        BarcodeScanCard(
          onAddPressed: () {
            // Add product logic here
          },
        ),
        const SizedBox(height: 20),
        CartSection(
          cartItems: dummyCartItems,
          onRemoveItem: (index) {
            // Remove item logic here
          },
          onIncreaseQty: (index) {
            // Increase quantity logic here
          },
          onDecreaseQty: (index) {
            // Decrease quantity logic here
          },
        ),
        const SizedBox(height: 20),
        TotalSectionCard(
          totalAmount: totalAmount,
          itemCount: dummyCartItems.length,
          onCheckout: () {
            // Checkout logic here
          },
          onClearCart: () {
            // Clear cart logic here
          },
        ),
      ],
    );
  }
}
