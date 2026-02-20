import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' hide State;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../data/arp_repository_impl.dart';
import '../../data/models/product_performance_model.dart';

class ArpMonthlyProductsSection extends StatefulWidget {
  final Map<String, double> monthlySales;

  const ArpMonthlyProductsSection({super.key, required this.monthlySales});

  @override
  State<ArpMonthlyProductsSection> createState() => _ArpMonthlyProductsSectionState();
}

class _ArpMonthlyProductsSectionState extends State<ArpMonthlyProductsSection> {
  String? _selectedMonth;
  List<ProductPerformanceModel> _products = [];
  bool _loading = false;

  static const _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String _monthLabel(String key) {
    final parts = key.split('-');
    if (parts.length == 2) {
      final m = int.tryParse(parts[1]);
      if (m != null && m >= 1 && m <= 12) {
        return '${_arabicMonths[m - 1]} ${parts[0]}';
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
      final repo = getIt<ArpRepositoryImpl>();
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
  void didUpdateWidget(ArpMonthlyProductsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.monthlySales != oldWidget.monthlySales && widget.monthlySales.isNotEmpty) {
      final latestMonth = widget.monthlySales.keys.last;
      _loadProducts(latestMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final months = widget.monthlySales.keys.toList();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : isTablet ? 24 : 16,
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
                  const Text(
                    'أكثر المنتجات مبيعاً بالشهر',
                    style: TextStyle(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [AppColors.secondaryColor, AppColors.primaryColor],
                                )
                              : null,
                          color: isSelected ? null : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          _monthLabel(month),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.mutedColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Selected month total
              if (_selectedMonth != null && widget.monthlySales.containsKey(_selectedMonth))
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
                      const Icon(Icons.monetization_on_rounded, color: AppColors.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'إجمالي ${_monthLabel(_selectedMonth!)}:',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.monthlySales[_selectedMonth]!.toStringAsFixed(2)} ج.م',
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
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  ),
                )
              else if (_products.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.mutedColor.withOpacity(0.4)),
                        const SizedBox(height: 8),
                        const Text(
                          'لا توجد منتجات في هذا الشهر',
                          style: TextStyle(color: AppColors.mutedColor),
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
    final maxRev = _products.isNotEmpty ? _products.first.revenue : 0.0;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = _products[index];
        final ratio = maxRev > 0 ? (product.revenue / maxRev) : 0.0;
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
                        colors: [AppColors.secondaryColor, AppColors.primaryColor],
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
                        '${product.revenue.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rank <= 3 ? AppColors.secondaryColor : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.quantitySold} قطعة',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedColor,
                        ),
                      ),
                    ],
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
