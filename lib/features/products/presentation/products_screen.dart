import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

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
      builder: (_) =>
          AddEditProductDialog(categories: categories, productToEdit: product),
    );

    if (result == null) return; // cancelled

    setState(() {
      if (product != null) {
        // edit
        final index = _products.indexOf(product);
        if (index != -1) _products[index] = result;
      } else {
        // add
        _products.add(result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: LayoutBuilderBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobile = width < 800;
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
                    Text(
                      'المنتجات',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'إدارة المنتجات والمخزون',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Filters
                    Card(
                      color: AppColors.surfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProductFilters(
                          isMobile: isMobile,
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Products list
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.borderColor),
                        ),
                        color: AppColors.surfaceColor,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 20,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'قائمة المنتجات',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isMobile ? 16 : 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffeef6f6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '(${filteredProducts.length})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: isMobile
                                    ? Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: ListView.builder(
                                          itemCount: filteredProducts.length,
                                          itemBuilder: (context, index) {
                                            final p = filteredProducts[index];
                                            return ProductCard(
                                              product: p,
                                              onDelete: () => setState(
                                                () => _products.remove(p),
                                              ),
                                              onEdit: () =>
                                                  _showAddEditDialog(p),
                                              statusColor: _statusColor(
                                                p['qty'],
                                                p['min'],
                                              ),
                                              statusText: _statusText(
                                                p['qty'],
                                                p['min'],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: ProductTable(
                                          products: filteredProducts,
                                          onDelete: (p) => setState(
                                            () => _products.remove(p),
                                          ),
                                          onEdit: (p) => _showAddEditDialog(p),
                                          statusColorFn: _statusColor,
                                          statusTextFn: _statusText,
                                        ),
                                      ),
                              ),
                            ],
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

// A tiny helper to avoid repeating LayoutBuilder boilerplate
class LayoutBuilderBuilder extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;
  const LayoutBuilderBuilder({required this.builder, super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: builder);
}

// ----------------- Product Filters Widget -----------------
class ProductFilters extends StatelessWidget {
  final bool isMobile;
  final TextEditingController searchController;
  final String categoryFilter;
  final String availabilityFilter;
  final List<String> categories;
  final List<String> availabilities;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onAvailabilityChanged;
  final VoidCallback onAddPressed;

  const ProductFilters({
    required this.isMobile,
    required this.searchController,
    required this.categoryFilter,
    required this.availabilityFilter,
    required this.categories,
    required this.availabilities,
    required this.onCategoryChanged,
    required this.onAvailabilityChanged,
    required this.onAddPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => (context as Element).markNeedsBuild(),
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: categoryFilter,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'الفئة',
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => onCategoryChanged(v ?? categoryFilter),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: availabilityFilter,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'التوفر',
                    ),
                    items: availabilities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        onAvailabilityChanged(v ?? availabilityFilter),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text('إضافة منتج جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0fa2a9),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop / Tablet layout
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: searchController,
              onChanged: (_) => (context as Element).markNeedsBuild(),
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: categoryFilter,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'حسب الفئة',
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => onCategoryChanged(v ?? categoryFilter),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: availabilityFilter,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'حسب التوفر',
              ),
              items: availabilities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => onAvailabilityChanged(v ?? availabilityFilter),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('إضافة منتج جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0fa2a9),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- Product Card (mobile) -----------------
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Color statusColor;
  final String statusText;

  const ProductCard({
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.statusColor,
    required this.statusText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final qty = product['qty'];
    final min = product['min'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'الكود: ${product['code']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'السعر',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${product['price']} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الكمية',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${product['qty']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: product['qty'] == 0
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الحد الأدنى',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${product['min']}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'الباركود: ${product['barcode']}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 16,
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

// ----------------- Product Table (desktop) -----------------
class ProductTable extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onEdit;
  final Color Function(int, int) statusColorFn;
  final String Function(int, int) statusTextFn;

  const ProductTable({
    required this.products,
    required this.onDelete,
    required this.onEdit,
    required this.statusColorFn,
    required this.statusTextFn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.78,
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),

        child: DataTable(
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          dataTextStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          headingRowHeight: 52,
          columnSpacing: 28,
          columns: const [
            DataColumn(label: Text('الكود')),
            DataColumn(label: Text('اسم المنتج')),
            DataColumn(label: Text('التصنيف')),
            DataColumn(label: Text('الباركود')),
            DataColumn(label: Text('السعر')),
            DataColumn(label: Text('الكمية')),
            DataColumn(label: Text('تاريخ الإضافة')),
            DataColumn(label: Text('الحالة')),
            DataColumn(label: Text('العمليات')),
          ],
          rows: products.map((p) {
            final qty = p['qty'] as int;
            final min = p['min'] as int;
            final created = p['createdAt'] as DateTime?;
            return DataRow(
              cells: [
                DataCell(Text(p['code'])),
                DataCell(Text(p['name'])),
                DataCell(Text(p['category'] ?? '---')),
                DataCell(
                  Text(
                    p['barcode'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${p['price']} ج.م',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  Text(
                    qty.toString(),
                    style: TextStyle(
                      color: qty == 0 ? Colors.red : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    created != null
                        ? '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')}'
                        : '---',
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColorFn(qty, min).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusTextFn(qty, min),
                      style: TextStyle(
                        color: statusColorFn(qty, min),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => onEdit(p),
                          icon: const Icon(
                            Icons.edit_square,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => onDelete(p),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ----------------- Add / Edit Dialog -----------------
class AddEditProductDialog extends StatefulWidget {
  final List<String> categories;
  final Map<String, dynamic>? productToEdit;

  const AddEditProductDialog({
    required this.categories,
    this.productToEdit,
    super.key,
  });

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  late final TextEditingController codeCtrl;
  late final TextEditingController nameCtrl;
  late final TextEditingController barcodeCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController qtyCtrl;
  late final TextEditingController minCtrl;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    codeCtrl = TextEditingController(text: p?['code'] ?? '');
    nameCtrl = TextEditingController(text: p?['name'] ?? '');
    barcodeCtrl = TextEditingController(text: p?['barcode'] ?? '');
    priceCtrl = TextEditingController(text: p?['price']?.toString() ?? '');
    qtyCtrl = TextEditingController(text: p?['qty']?.toString() ?? '');
    minCtrl = TextEditingController(text: p?['min']?.toString() ?? '');
    selectedCategory =
        p?['category'] ??
        (widget.categories.isNotEmpty ? widget.categories.first : '');
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    nameCtrl.dispose();
    barcodeCtrl.dispose();
    priceCtrl.dispose();
    qtyCtrl.dispose();
    minCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) return;
    final Map<String, dynamic> out = {
      'code': codeCtrl.text.trim(),
      'name': nameCtrl.text.trim(),
      'barcode': barcodeCtrl.text.trim(),
      'price': int.tryParse(priceCtrl.text) ?? 0,
      'qty': int.tryParse(qtyCtrl.text) ?? 0,
      'min': int.tryParse(minCtrl.text) ?? 0,
      'category': selectedCategory,
      'createdAt': widget.productToEdit?['createdAt'] ?? DateTime.now(),
    };
    Navigator.of(context).pop(out);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 520;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWide ? 720 : MediaQuery.of(context).size.width * 0.95,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.productToEdit == null
                        ? 'إضافة منتج جديد'
                        : 'تعديل المنتج',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // form fields (two columns on wide)
              isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: codeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'كود المنتج *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'اسم المنتج *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        TextField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'كود المنتج *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'اسم المنتج *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 12),
              isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: barcodeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'رقم الباركود',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'السعر بالجنيه المصري *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        TextField(
                          controller: barcodeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'رقم الباركود',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'السعر بالجنيه المصري *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 12),
              isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'الكمية المتوفرة *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: minCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'الحد الأدنى للمخزون',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الكمية المتوفرة *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الحد الأدنى للمخزون',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: widget.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => selectedCategory = v ?? selectedCategory),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'الفئة',
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0fa2a9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      widget.productToEdit == null
                          ? 'إضافة المنتج'
                          : 'حفظ التعديلات',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
