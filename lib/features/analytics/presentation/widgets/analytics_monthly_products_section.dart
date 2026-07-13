import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/analytics_repository_impl.dart';
import '../../../sessions/data/models/product_performance_model.dart';

class AnalyticsMonthlyProductsSection extends StatefulWidget {
  final Map<String, double> monthlySales;

  const AnalyticsMonthlyProductsSection(
      {super.key, required this.monthlySales});

  @override
  State<AnalyticsMonthlyProductsSection> createState() =>
      _AnalyticsMonthlyProductsSectionState();
}

class _AnalyticsMonthlyProductsSectionState
    extends State<AnalyticsMonthlyProductsSection> {
  String? _selectedMonth;
  List<ProductPerformanceModel> _products = [];
  bool _loading = false;

  List<String> _getArabicMonths(AppLocalizations l10n) => [
    l10n.monthJan,
    l10n.monthFeb,
    l10n.monthMar,
    l10n.monthApr,
    l10n.monthMay,
    l10n.monthJun,
    l10n.monthJul,
    l10n.monthAug,
    l10n.monthSep,
    l10n.monthOct,
    l10n.monthNov,
    l10n.monthDec,
  ];

  String _monthLabel(String key, AppLocalizations l10n) {
    final parts = key.split('-');
    if (parts.length == 2) {
      final m = int.tryParse(parts[1]);
      if (m != null && m >= 1 && m <= 12) {
        return '${_getArabicMonths(l10n)[m - 1]} ${parts[0]}';
      }
    }
    return key;
  }

  Future<void> _loadProducts(String yearMonth) async {
    setState(() {
      _selectedMonth = yearMonth;
      _loading = true;
    });

    try {
      final repo = getIt<AnalyticsRepositoryImpl>();
      final result = await repo.getTopProductsForMonth(yearMonth, 10);
      result.fold(
        (_) => setState(() => _loading = false),
        (products) => setState(() {
          _products = products;
          _loading = false;
        }),
      );
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-select latest month
    if (widget.monthlySales.isNotEmpty) {
      final latestMonth = widget.monthlySales.keys.last;
      _loadProducts(latestMonth);
    }
  }

  @override
  void didUpdateWidget(AnalyticsMonthlyProductsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.monthlySales != oldWidget.monthlySales &&
        widget.monthlySales.isNotEmpty) {
      final latestMonth = widget.monthlySales.keys.last;
      _loadProducts(latestMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final months = widget.monthlySales.keys.toList();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? 32
            : isTablet
                ? 24
                : 16,
      ),
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: AppColors.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.topProductsByMonth,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kDarkChip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Month selector chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: months.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final isSelected = _selectedMonth == month;
                    return GestureDetector(
                      onTap: () => _loadProducts(month),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.secondaryColor,
                                    AppColors.primaryColor
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          _monthLabel(month, l10n),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.mutedColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Selected month total
              if (_selectedMonth != null &&
                  widget.monthlySales.containsKey(_selectedMonth))
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.totalLabel(_monthLabel(_selectedMonth!, l10n))}:',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.monthlySales[_selectedMonth]!.toStringAsFixed(2)} ${l10n.currencyEg}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              // Products list
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                        color: AppColors.primaryColor),
                  ),
                )
              else if (_products.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 48,
                            color: AppColors.mutedColor.withOpacity(0.4)),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noProductsThisMonth,
                          style: const TextStyle(color: AppColors.mutedColor),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildProductsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    final l10n = AppLocalizations.of(context);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = _products[index];
        final rank = index + 1;

        return Row(
          children: [
            // Rank badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: rank <= 3
                    ? const LinearGradient(
                        colors: [
                          AppColors.secondaryColor,
                          AppColors.primaryColor
                        ],
                      )
                    : null,
                color: rank > 3 ? Colors.grey.shade100 : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: rank <= 3 ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${product.revenue.toStringAsFixed(0)} ${l10n.currencyEg}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.soldCount(product.quantitySold),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
