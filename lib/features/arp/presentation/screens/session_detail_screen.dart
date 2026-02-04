import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../data/models/session_model.dart';

import '../../domain/arp_repository.dart';
import '../../../auth/domain/repository/user_repository_int.dart';
import '../../data/models/product_performance_model.dart';
import '../widgets/arp_extra_charts.dart';
import '../widgets/arp_top_products.dart';

class SessionDetailScreen extends StatefulWidget {
  final Session session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final _arpRepo = getIt<ArpRepository>();
  final _userRepo = getIt<UserRepositoryInt>();
  bool _loading = true;
  
  Map<int, double> _hourlySales = {};
  Map<String, double> _categorySales = {};
  List<ProductPerformanceModel> _topProducts = [];
  
  double _totalSales = 0.0;
  double _totalRefunds = 0.0;
  int _totalTransactions = 0;
  
  String? _openedByName;
  String? _closedByName;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _loadUserNames();
  }

  Future<void> _loadUserNames() async {
    // Load opened by user name
    final openedByResult = await _userRepo.getUser(widget.session.openedByUserId);
    openedByResult.fold(
      (failure) => debugPrint('Failed to load opened by user'),
      (user) => setState(() => _openedByName = user.name),
    );
    
    // Load closed by user name if exists
    if (widget.session.closedByUserId != null) {
      final closedByResult = await _userRepo.getUser(widget.session.closedByUserId!);
      closedByResult.fold(
        (failure) => debugPrint('Failed to load closed by user'),
        (user) => setState(() => _closedByName = user.name),
      );
    }
  }

  Future<void> _loadSessionData() async {
    setState(() => _loading = true);
    
    try {
      // Load session report to get totals
      final reportResult = await _arpRepo.getReportForSession(widget.session.id);
      reportResult.fold(
        (failure) {
          debugPrint('Failed to load report: ${failure.message}');
        },
        (report) {
          if (report != null) {
            setState(() {
              _totalSales = report.totalSales;
              _totalRefunds = report.totalRefunds;
              _totalTransactions = report.totalTransactions;
            });
          }
        },
      );
      
      // Load hourly sales
      final hourlyResult = await _arpRepo.getHourlySalesForSession(widget.session.id);
      hourlyResult.fold(
        (failure) => debugPrint('Failed to load hourly: ${failure.message}'),
        (data) => setState(() => _hourlySales = data),
      );
      
      // Load category sales
      final categoryResult = await _arpRepo.getCategorySalesForSession(widget.session.id);
      categoryResult.fold(
        (failure) => debugPrint('Failed to load categories: ${failure.message}'),
        (data) => setState(() => _categorySales = data),
      );
      
      // Load top products
      final productsResult = await _arpRepo.getTopProductsForSession(widget.session.id, 10);
      productsResult.fold(
        (failure) => debugPrint('Failed to load products: ${failure.message}'),
        (data) => setState(() => _topProducts = data),
      );
      
    } catch (e) {
      debugPrint('Error loading session data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text('تفاصيل الجلسة #${widget.session.id}'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 32 : isTablet ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSessionHeader(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildSummaryCards(isDesktop, isTablet),
                    SizedBox(height: isDesktop ? 32 : 24),
                    if (_hourlySales.isNotEmpty) ...[
                      ArpHourlyChart(hourlySales: _hourlySales),
                      SizedBox(height: isDesktop ? 32 : 24),
                    ],
                    if (_categorySales.isNotEmpty) ...[
                      ArpCategoryPieChart(categorySales: _categorySales),
                      SizedBox(height: isDesktop ? 32 : 24),
                    ],
                    if (_topProducts.isNotEmpty) ...[
                      ArpTopProducts(products: _topProducts),
                      SizedBox(height: isDesktop ? 32 : 24),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSessionHeader(bool isDesktop, bool isTablet) {
    final openTime = widget.session.openTime;
    final closeTime = widget.session.closeTime;
    final duration = closeTime != null 
        ? closeTime.difference(openTime)
        : Duration.zero;
    
    final durationText = duration.inHours > 0
        ? '${duration.inHours} ساعة ${duration.inMinutes % 60} دقيقة'
        : '${duration.inMinutes} دقيقة';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_note,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جلسة #${widget.session.id}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.kDarkChip,
                      ),
                    ),
                    Text(
                      widget.session.isOpen ? 'جلسة مفتوحة' : 'جلسة مغلقة',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.session.isOpen ? AppColors.successColor : AppColors.mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow('وقت الفتح', DateFormat('yyyy-MM-dd HH:mm').format(openTime)),
          if (closeTime != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('وقت الإغلاق', DateFormat('yyyy-MM-dd HH:mm').format(closeTime)),
            const SizedBox(height: 12),
            _buildInfoRow('المدة', durationText),
          ],
          const SizedBox(height: 12),
          _buildInfoRow('فتح بواسطة', _openedByName ?? widget.session.openedByUserId),
          if (widget.session.closedByUserId != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow('أغلق بواسطة', _closedByName ?? widget.session.closedByUserId!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.kDarkChip,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(bool isDesktop, bool isTablet) {
    final netRevenue = _totalSales - _totalRefunds;
    
    final cards = [
      _SummaryCard(
        title: 'إجمالي المبيعات',
        value: '${_totalSales.toStringAsFixed(2)} ج.م',
        icon: Icons.attach_money,
        color: AppColors.primaryColor,
      ),
      _SummaryCard(
        title: 'المرتجعات',
        value: '${_totalRefunds.toStringAsFixed(2)} ج.م',
        icon: Icons.assignment_return,
        color: AppColors.errorColor,
      ),
      _SummaryCard(
        title: 'صافي الإيرادات',
        value: '${netRevenue.toStringAsFixed(2)} ج.م',
        icon: Icons.account_balance_wallet,
        color: AppColors.successColor,
      ),
      _SummaryCard(
        title: 'عدد المعاملات',
        value: _totalTransactions.toString(),
        icon: Icons.receipt_long,
        color: AppColors.secondaryColor,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: card,
                  ),
                ))
            .toList(),
      );
    } else if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: Padding(padding: const EdgeInsets.all(4), child: cards[0])),
              Expanded(child: Padding(padding: const EdgeInsets.all(4), child: cards[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Padding(padding: const EdgeInsets.all(4), child: cards[2])),
              Expanded(child: Padding(padding: const EdgeInsets.all(4), child: cards[3])),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: card,
        )).toList(),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
