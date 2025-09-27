import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';

// Custom Widgets

// Header Widget
class ProductsScreenHeader extends StatelessWidget {
  const ProductsScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                'المنتجات',
                style: TextStyle(
                  fontSize: isMobile ? 22 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'إدارة المنتجات والمخزون',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        );
      },
    );
  }
}

// Enhanced Filter Section Widget
class ProductsFilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final String categoryFilter;
  final String availabilityFilter;
  final List<String> categories;
  final List<String> availabilities;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onAvailabilityChanged;
  final VoidCallback onAddPressed;
  final VoidCallback onSearchChanged;

  const ProductsFilterSection({
    super.key,
    required this.searchController,
    required this.categoryFilter,
    required this.availabilityFilter,
    required this.categories,
    required this.availabilities,
    required this.onCategoryChanged,
    required this.onAvailabilityChanged,
    required this.onAddPressed,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Filter Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff0fa2a9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Color(0xff0fa2a9),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'البحث والفلترة',
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

              // Search and Filters
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return _buildDesktopLayout();
                  } else {
                    return _buildMobileLayout();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'ابحث عن منتج بالاسم، الكود، الباركود أو السعر...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xff0fa2a9),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Filters Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildDropdownFilter(
                'حسب الفئة',
                categoryFilter,
                categories,
                onCategoryChanged,
                Icons.category_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildDropdownFilter(
                'حسب التوفر',
                availabilityFilter,
                availabilities,
                onAvailabilityChanged,
                Icons.inventory_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: _buildAddButton(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'ابحث عن منتج...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xff0fa2a9),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Filters
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(
                'الفئة',
                categoryFilter,
                categories,
                onCategoryChanged,
                Icons.category_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownFilter(
                'التوفر',
                availabilityFilter,
                availabilities,
                onAvailabilityChanged,
                Icons.inventory_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xff0fa2a9)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(item),
                  ),
                ))
            .toList(),
        onChanged: (v) => onChanged(v ?? value),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0fa2a9),
            Color(0xff0891a6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0fa2a9).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onAddPressed,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text(
            'إضافة منتج جديد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Enhanced Product Card Widget
class EnhancedProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Color statusColor;
  final String statusText;

  const EnhancedProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.statusColor,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final qty = product['qty'] as int;
    final min = product['min'] as int;
    final isLowStock = qty > 0 && qty < min;
    final isOutOfStock = qty == 0;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red.withOpacity(0.3)
              : isLowStock
                  ? Colors.orange.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with product name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          product['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'كود: ${product['code']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),

            const SizedBox(height: 16),

            // Product Info Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'السعر',
                          '${product['price']} ج.م',
                          Icons.attach_money,
                          const Color(0xff059669),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'الكمية',
                          product['qty'].toString(),
                          Icons.inventory_2_outlined,
                          qty == 0 ? Colors.red : const Color(0xff0fa2a9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'الحد الأدنى',
                          product['min'].toString(),
                          Icons.trending_down,
                          const Color(0xfff59e0b),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'الفئة',
                          product['category'] ?? '---',
                          Icons.category_outlined,
                          const Color(0xff8b5cf6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Barcode
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'باركود: ${product['barcode']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'تعديل',
                    Icons.edit_outlined,
                    Colors.grey.shade600,
                    onEdit,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'حذف',
                    Icons.delete_outline,
                    Colors.red,
                    onDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Products Grid View Widget
class ProductsGridView extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onEdit;
  final Color Function(int, int) statusColorFn;
  final String Function(int, int) statusTextFn;

  const ProductsGridView({
    super.key,
    required this.products,
    required this.onDelete,
    required this.onEdit,
    required this.statusColorFn,
    required this.statusTextFn,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 1400) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 1000) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 700) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return products.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final qty = product['qty'] as int;
                  final min = product['min'] as int;
                  
                  return EnhancedProductCard(
                    product: product,
                    onDelete: () => onDelete(product),
                    onEdit: () => onEdit(product),
                    statusColor: statusColorFn(qty, min),
                    statusText: statusTextFn(qty, min),
                  );
                },
              );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على منتجات تطابق البحث',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Add/Edit Dialog
class EnhancedAddEditProductDialog extends StatefulWidget {
  final List<String> categories;
  final Map<String, dynamic>? productToEdit;

  const EnhancedAddEditProductDialog({
    super.key,
    required this.categories,
    this.productToEdit,
  });

  @override
  State<EnhancedAddEditProductDialog> createState() =>
      _EnhancedAddEditProductDialogState();
}

class _EnhancedAddEditProductDialogState
    extends State<EnhancedAddEditProductDialog> {
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
    selectedCategory = p?['category'] ??
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff0fa2a9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.productToEdit == null
                          ? Icons.add_box_outlined
                          : Icons.edit_outlined,
                      color: const Color(0xff0fa2a9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        widget.productToEdit == null
                            ? 'إضافة منتج جديد'
                            : 'تعديل المنتج',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form
              Flexible(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 500;
                      return Column(
                        children: [
                          if (isWide) ...[
                            _buildTwoColumnRow([
                              _buildTextField(codeCtrl, 'كود المنتج *', Icons.qr_code),
                              _buildTextField(nameCtrl, 'اسم المنتج *', Icons.inventory_2),
                            ]),
                            const SizedBox(height: 16),
                            _buildTwoColumnRow([
                              _buildTextField(barcodeCtrl, 'رقم الباركود', Icons.qr_code_scanner),
                              _buildTextField(priceCtrl, 'السعر بالجنيه المصري *', Icons.attach_money, TextInputType.number),
                            ]),
                            const SizedBox(height: 16),
                            _buildTwoColumnRow([
                              _buildTextField(qtyCtrl, 'الكمية المتوفرة *', Icons.inventory, TextInputType.number),
                              _buildTextField(minCtrl, 'الحد الأدنى للمخزون', Icons.trending_down, TextInputType.number),
                            ]),
                          ] else ...[
                            _buildTextField(codeCtrl, 'كود المنتج *', Icons.qr_code),
                            const SizedBox(height: 16),
                            _buildTextField(nameCtrl, 'اسم المنتج *', Icons.inventory_2),
                            const SizedBox(height: 16),
                            _buildTextField(barcodeCtrl, 'رقم الباركود', Icons.qr_code_scanner),
                            const SizedBox(height: 16),
                            _buildTextField(priceCtrl, 'السعر بالجنيه المصري *', Icons.attach_money, TextInputType.number),
                            const SizedBox(height: 16),
                            _buildTextField(qtyCtrl, 'الكمية المتوفرة *', Icons.inventory, TextInputType.number),
                            const SizedBox(height: 16),
                            _buildTextField(minCtrl, 'الحد الأدنى للمخزون', Icons.trending_down, TextInputType.number),
                          ],
                          const SizedBox(height: 16),
                          _buildCategoryDropdown(),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0fa2a9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.productToEdit == null
                              ? 'إضافة المنتج'
                              : 'حفظ التعديلات',
                        ),
                      ),
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

  Widget _buildTwoColumnRow(List<Widget> children) {
    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 16),
        Expanded(child: children[1]),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType? keyboardType,
  ]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xff0fa2a9)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        items: widget.categories
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ))
            .toList(),
        onChanged: (v) => setState(() => selectedCategory = v ?? selectedCategory),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'الفئة',
          prefixIcon: Icon(Icons.category, color: Color(0xff0fa2a9)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// Main Products Screen
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
                    const ProductsScreenHeader(),
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
                    const SizedBox(height: 20),

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
                    const SizedBox(height: 16),

                    // Products Grid - Expanded to fill remaining space
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
                            onDelete: (p) => setState(() => _products.remove(p)),
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