import 'package:flutter/material.dart';

class FilterButtonsWidget extends StatelessWidget {
  final String filter;
  final int totalCount;
  final int lowStockCount;
  final int outOfStockCount;
  final Function(String) onFilterChanged;

  const FilterButtonsWidget({
    super.key,
    required this.filter,
    required this.totalCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Filter Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: Color(0xFF06B6D4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'فلترة المنتجات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Buttons
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // Desktop/Tablet - Row layout
                    return Row(
                      children: [
                        Expanded(
                          child: _buildFilterCard(
                            'جميع المنتجات',
                            totalCount,
                            'all',
                            Icons.inventory_2_outlined,
                            const Color(0xFF06B6D4),
                            'عرض جميع المنتجات',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFilterCard(
                            'مخزون منخفض',
                            lowStockCount,
                            'low',
                            Icons.warning_amber_rounded,
                            const Color(0xFFF59E0B),
                            'المنتجات التي تحتاج إعادة تخزين',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFilterCard(
                            'غير متوفر',
                            outOfStockCount,
                            'out',
                            Icons.cancel_outlined,
                            const Color(0xFFEF4444),
                            'المنتجات المنتهية الصلاحية',
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Mobile - Column layout
                    return Column(
                      children: [
                        _buildFilterCard(
                          'جميع المنتجات',
                          totalCount,
                          'all',
                          Icons.inventory_2_outlined,
                          const Color(0xFF06B6D4),
                          'عرض جميع المنتجات',
                        ),
                        const SizedBox(height: 12),
                        _buildFilterCard(
                          'مخزون منخفض',
                          lowStockCount,
                          'low',
                          Icons.warning_amber_rounded,
                          const Color(0xFFF59E0B),
                          'المنتجات التي تحتاج إعادة تخزين',
                        ),
                        const SizedBox(height: 12),
                        _buildFilterCard(
                          'غير متوفر',
                          outOfStockCount,
                          'out',
                          Icons.cancel_outlined,
                          const Color(0xFFEF4444),
                          'المنتجات المنتهية الصلاحية',
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCard(
    String title,
    int count,
    String filterValue,
    IconData icon,
    Color color,
    String description,
  ) {
    final isSelected = filter == filterValue;

    return GestureDetector(
      onTap: () => onFilterChanged(filterValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'العدد:',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
