import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
            colors: [Colors.white, AppColors.surfaceColor],
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
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.productToEdit == null
                          ? Icons.add_box_outlined
                          : Icons.edit_outlined,
                      color: AppColors.primaryColor,
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
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.primaryForeground,
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
        border: Border.all(color: AppColors.borderColor),
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
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
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
        border: Border.all(color: AppColors.borderColor),
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
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: 'الفئة',
          prefixIcon: Icon(Icons.category, color: AppColors.primaryColor),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
