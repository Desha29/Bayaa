import 'package:crazy_phone_pos/features/products/data/models/product_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../cubit/product_cubit.dart';

import 'package:crazy_phone_pos/core/constants/app_colors.dart';

class EnhancedAddEditProductDialog extends StatefulWidget {
  final List<String> categories;
  final Product? productToEdit;

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
  late final TextEditingController? codeCtrl;
  late final TextEditingController nameCtrl;
  late final TextEditingController barcodeCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController qtyCtrl;
  late final TextEditingController minQtyCtrl;
  late final TextEditingController minPriceCtrl;
  late final TextEditingController wholesalePriceCtrl;

  late String selectedCategory;
  final _formKey = GlobalKey<FormState>(); // ✅ مفتاح النموذج للتحقق

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    nameCtrl = TextEditingController(text: p?.name ?? '');
    barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    priceCtrl = TextEditingController(text: p?.price.toString() ?? '');
    qtyCtrl = TextEditingController(text: p?.quantity.toString() ?? '');
    minQtyCtrl = TextEditingController(text: p?.minQuantity.toString() ?? '');
    minPriceCtrl = TextEditingController(text: p?.minPrice.toString() ?? '');
    wholesalePriceCtrl =
        TextEditingController(text: p?.wholesalePrice.toString() ?? '');
    
    // Filter out "الكل" from valid categories
    final validCategories = widget.categories.where((c) => c != 'الكل').toList();
    
    // Set initial category, ensuring it's not "الكل"
    if (p?.category != null && p!.category != 'الكل' && validCategories.contains(p.category)) {
      selectedCategory = p.category;
    } else {
      selectedCategory = validCategories.isNotEmpty ? validCategories.first : '';
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    barcodeCtrl.dispose();
    priceCtrl.dispose();
    qtyCtrl.dispose();
    minQtyCtrl.dispose();
    minPriceCtrl.dispose();
    wholesalePriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // ✅ تحقق من جميع الحقول قبل الحفظ
    if (!_formKey.currentState!.validate()) return;

    final barcode = barcodeCtrl.text.trim();
    
    // Check for duplicates if adding new product
    if (widget.productToEdit == null) {
      if (!mounted) return;
      final exists = await getIt<ProductCubit>().checkProductExists(barcode);
      if (!mounted) return;
      
      if (exists) {
         // Show simple dialog or snackbar. Since it's a dialog, a snackbar might be behind it or on top?
         // Dialog is safe.
         showDialog(
           context: context,
           builder: (ctx) => AlertDialog(
             title: const Row(children: [
               Icon(Icons.error_outline, color: AppColors.errorColor),
               SizedBox(width: 8),
               Text('خطأ في الباركود'),
             ]),
             content: Text('المنتج ذو الباركود "$barcode" موجود بالفعل.\nالرجاء استخدام باركود مختلف أو تعديل المنتج الموجود.'),
             actions: [
               TextButton(
                 onPressed: () => Navigator.pop(ctx), 
                 child: const Text('حسناً')
               )
             ],
           )
         );
         return;
      }
    }

    final productSave = Product(
      wholesalePrice: double.tryParse(wholesalePriceCtrl.text.trim()) ?? 0.0,
      minPrice: double.tryParse(minPriceCtrl.text.trim()) ?? 0.0,
      name: nameCtrl.text.trim(),
      barcode: barcode,
      price: double.tryParse(priceCtrl.text.trim()) ?? 0.0,
      quantity: int.tryParse(qtyCtrl.text.trim()) ?? 0,
      minQuantity: int.tryParse(minQtyCtrl.text.trim()) ?? 0,
      category: selectedCategory,
    );
    
    if (!mounted) return;
    getIt<ProductCubit>().saveProduct(productSave);
    getIt<NotificationsCubit>().addItem(productSave);

    Navigator.of(context).pop();
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
                      return Form(
                        key: _formKey, // ✅ مفتاح التحقق
                        child: Column(
                          children: [
                            if (isWide) ...[
                              _buildTwoColumnRow([
                                _buildTextField(
                                    nameCtrl, 'اسم المنتج', Icons.inventory_2),
                                _buildTextField(
                                  barcodeCtrl,
                                  'رقم الباركود',
                                  readOnly: (widget.productToEdit == null)
                                      ? false
                                      : true,
                                  Icons.qr_code_scanner,
                                )
                              ]),
                              const SizedBox(height: 16),
                              _buildTextField(wholesalePriceCtrl, 'سعر الجملة',
                                  Icons.price_change,
                                  keyboardType: TextInputType.number),
                              const SizedBox(height: 16),
                              _buildTwoColumnRow([
                                _buildTextField(minPriceCtrl, 'الحد الأدنى للسعر',
                                    Icons.price_change,
                                    keyboardType: TextInputType.number),
                                _buildTextField(priceCtrl, 'السعر بالجنيه المصري',
                                    Icons.attach_money,
                                    keyboardType: TextInputType.number),
                              ]),
                              const SizedBox(height: 16),
                              _buildTwoColumnRow([
                                _buildTextField(qtyCtrl, 'الكمية المتوفرة',
                                    Icons.inventory,
                                    keyboardType: TextInputType.number),
                                _buildTextField(minQtyCtrl, 'الحد الأدنى للمخزون',
                                    Icons.trending_down,
                                    keyboardType: TextInputType.number),
                              ]),
                            ] else ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                  nameCtrl, 'اسم المنتج', Icons.inventory_2),
                              const SizedBox(height: 16),
                              _buildTextField(barcodeCtrl, 'رقم الباركود',
                                  Icons.qr_code_scanner),
                              const SizedBox(height: 16),
                              _buildTextField(priceCtrl, 'السعر بالجنيه المصري',
                                  Icons.attach_money,
                                  keyboardType: TextInputType.number),
                              const SizedBox(height: 16),
                              _buildTextField(qtyCtrl, 'الكمية المتوفرة',
                                  Icons.inventory,
                                  keyboardType: TextInputType.number),
                              const SizedBox(height: 16),
                              _buildTextField(minQtyCtrl, 'الحد الأدنى للمخزون',
                                  Icons.trending_down,
                                  keyboardType: TextInputType.number),
                            ],
                            const SizedBox(height: 16),
                            _buildCategoryDropdown(),
                          ],
                        ),
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

  Widget _buildCategoryDropdown() {
    // Filter out "الكل" (All) - it's only a UI filter, not a real category
    final validCategories = widget.categories.where((c) => c != 'الكل').toList();
    
    // Ensure selected category is valid
    if (selectedCategory == 'الكل' && validCategories.isNotEmpty) {
      selectedCategory = validCategories.first;
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.mutedColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: validCategories.contains(selectedCategory) ? selectedCategory : (validCategories.isNotEmpty ? validCategories.first : null),
        items: validCategories
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ))
            .toList(),
        onChanged: (v) =>
            setState(() => selectedCategory = v ?? selectedCategory),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: 'الفئة',
          prefixIcon: Icon(Icons.category, color: AppColors.primaryColor),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty || value == 'الكل') {
            return 'يجب اختيار فئة صالحة';
          }
          return null;
        },
      ),
    );
  }
}

class AddCategories extends StatelessWidget {
  AddCategories({super.key});
  final TextEditingController nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // ✅ للتحقق

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
                      Icons.add_box_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'إضافة صنف جديد',
                        style: TextStyle(
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
                  child: Form(
                    key: _formKey, // ✅ للتحقق
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 500;
                        return Column(children: [
                          if (isWide) ...[
                            _buildTextField(
                                nameCtrl, 'اسم الصنف', Icons.inventory_2),
                          ],
                        ]);
                      },
                    ),
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
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        getIt<ProductCubit>().saveCategory(nameCtrl.text);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('إضافة صنف'),
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
  IconData icon, {
  TextInputType? keyboardType,
  bool readOnly = false,
}) {
  return TextFormField(
    readOnly: readOnly,
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
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'هذا الحقل مطلوب';
      }
      if (keyboardType == TextInputType.number &&
          double.tryParse(value.trim()) == null) {
        return 'يجب إدخال رقم صالح';
      }
      return null;
    },
  );
}
