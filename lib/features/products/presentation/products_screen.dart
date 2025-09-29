import 'package:crazy_phone_pos/core/components/screen_header.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/enhanced_add_edit_Dialog.dart';
import 'widgets/product_filter_section.dart';
import 'widgets/product_grid_view.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _categoryFilter = 'جميع الفئات';
  String _availabilityFilter = 'جميع الحالات';

  final List<String> categories = ['جميع الفئات', 'آيفون', 'سامسونج', 'هواوي'];
  final List<String> availabilities = [
    'جميع الحالات',
    'متوفر',
    'مخزون منخفض',
    'غير متوفر',
  ];

  final List<Map<String, dynamic>> _products = [
    {
      "code": "IP14P",
      "name": "آيفون 14 برو",
      "barcode": "1234567890123",
      "price": 4500,
      "qty": 15,
      "min": 5,
      "category": "آيفون",
      "createdAt": DateTime(2024, 3, 1),
    },
    {
      "code": "SGS23",
      "name": "سامسونج جالاكسي S23",
      "barcode": "2345678901234",
      "price": 3200,
      "qty": 3,
      "min": 5,
      "category": "سامسونج",
      "createdAt": DateTime(2024, 4, 12),
    },
    {
      "code": "IP13",
      "name": "آيفون 13",
      "barcode": "3456789012345",
      "price": 3800,
      "qty": 0,
      "min": 3,
      "category": "آيفون",
      "createdAt": DateTime(2023, 11, 20),
    },
    {
      "code": "HW30P",
      "name": "هواوي P30 برو",
      "barcode": "4567890123456",
      "price": 2100,
      "qty": 8,
      "min": 4,
      "category": "هواوي",
      "createdAt": DateTime(2024, 1, 5),
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    final q = _searchController.text.trim();
    return _products.where((p) {
      if (_categoryFilter != 'جميع الفئات' && p['category'] != _categoryFilter)
        return false;
      final qty = p['qty'] as int;
      if (_availabilityFilter == 'متوفر' && qty == 0) return false;
      if (_availabilityFilter == 'مخزون منخفض' && !(qty > 0 && qty < p['min']))
        return false;
      if (_availabilityFilter == 'غير متوفر' && qty != 0) return false;
      if (q.isNotEmpty) {
        final low = q.toLowerCase();
        return p['name'].toString().toLowerCase().contains(low) ||
            p['code'].toString().toLowerCase().contains(low) ||
            p['barcode'].toString().contains(low) ||
            p['price'].toString().contains(low);
      }
      return true;
    }).toList();
  }

  Color _statusColor(int qty, int min) {
    if (qty == 0) return const Color(0xFFD14343);
    if (qty < min) return const Color(0xFFF0A23B);
    return const Color(0xFF1E9A68);
  }

  String _statusText(int qty, int min) {
    if (qty == 0) return 'غير متوفر';
    if (qty < min) return 'مخزون منخفض';
    return 'متوفر';
  }

  void _showAddEditDialog([Map<String, dynamic>? product]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => EnhancedAddEditProductDialog(
        categories: categories,
        productToEdit: product,
      ),
    );

    if (result == null) return;

    setState(() {
      if (product != null) {
        final index = _products.indexOf(product);
        if (index != -1) _products[index] = result;
      } else {
        _products.add(result);
      }
    });
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 800;
              final horizontalPadding = isMobile ? 12.0 : 20.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const ScreenHeader(
                      title: "المنتجات",
                      subtitle: "إدارة المنتجات والمخزون",
                    ),
                    const SizedBox(height: 20),

                    // Enhanced Filters
                    ProductsFilterSection(
                      searchController: _searchController,
                      categoryFilter: _categoryFilter,
                      availabilityFilter: _availabilityFilter,
                      categories: categories,
                      availabilities: availabilities,
                      onCategoryChanged: (v) =>
                          setState(() => _categoryFilter = v),
                      onAvailabilityChanged: (v) =>
                          setState(() => _availabilityFilter = v),
                      onAddPressed: () => _showAddEditDialog(),
                      onSearchChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 10),

                    // Products Grid Header
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                      color: AppColors.surfaceColor,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              color: const Color(0xff0fa2a9),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'قائمة المنتجات',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 16 : 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff0fa2a9).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '(${filteredProducts.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xff0fa2a9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Products Grid
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.borderColor),
                        ),
                        color: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ProductsGridView(
                            products: filteredProducts,
                            onDelete: (p) =>
                                setState(() => _products.remove(p)),
                            onEdit: (p) => _showAddEditDialog(p),
                            statusColorFn: _statusColor,
                            statusTextFn: _statusText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
