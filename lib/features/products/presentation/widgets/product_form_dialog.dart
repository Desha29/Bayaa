import 'package:bayaa_pos/shared/widgets/forms/preview_form_fields.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

class ProductFormDialog extends StatefulWidget {
  final List<String> categories;
  final ProductViewData? productToEdit;

  const ProductFormDialog({
    super.key,
    required this.categories,
    this.productToEdit,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  late final TextEditingController nameCtrl;
  late final TextEditingController barcodeCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController qtyCtrl;
  late final TextEditingController minQtyCtrl;
  late final TextEditingController minPriceCtrl;
  late final TextEditingController wholesalePriceCtrl;

  late String selectedCategory;
  String? _selectedImagePath;
  final bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

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
    _selectedImagePath = p?.imagePath;

    // Filter out "All" from valid categories
    final validCategories = widget.categories.where((c) => c != 'All').toList();

    // Set initial category, ensuring it's not "All"
    if (p?.category != null &&
        p!.category != 'All' &&
        validCategories.contains(p.category)) {
      selectedCategory = p.category;
    } else {
      selectedCategory =
          validCategories.isNotEmpty ? validCategories.first : '';
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final feedbackContext = navigator.context;
    navigator.pop();
    showPreviewAction(feedbackContext);
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.surfaceColor,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            ? l10n.addNewProduct
                            : l10n.editProduct,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.localeName == 'ar' ? 'إغلاق' : 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildImagePicker(l10n),
              const SizedBox(height: 20),
              // Form
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (isWide) ...[
                          AdaptiveFormRow(children: [
                            buildPreviewTextField(context, nameCtrl,
                                l10n.productName, Icons.inventory_2),
                            buildPreviewTextField(
                              context,
                              barcodeCtrl,
                              l10n.barcodeNumber,
                              readOnly:
                                  (widget.productToEdit == null) ? false : true,
                              Icons.qr_code_scanner,
                            )
                          ]),
                          const SizedBox(height: 16),
                          buildPreviewTextField(context, wholesalePriceCtrl,
                              l10n.wholesalePriceLabel, Icons.price_change,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          AdaptiveFormRow(children: [
                            buildPreviewTextField(context, minPriceCtrl,
                                l10n.minPriceLabel2, Icons.price_change,
                                keyboardType: TextInputType.number),
                            buildPreviewTextField(context, priceCtrl,
                                l10n.sellingPrice, Icons.attach_money,
                                keyboardType: TextInputType.number),
                          ]),
                          const SizedBox(height: 16),
                          AdaptiveFormRow(children: [
                            buildPreviewTextField(context, qtyCtrl,
                                l10n.availableQty, Icons.inventory,
                                keyboardType: TextInputType.number),
                            buildPreviewTextField(context, minQtyCtrl,
                                l10n.minStockLevel, Icons.trending_down,
                                keyboardType: TextInputType.number),
                          ]),
                        ] else ...[
                          const SizedBox(height: 16),
                          buildPreviewTextField(context, nameCtrl,
                              l10n.productName, Icons.inventory_2),
                          const SizedBox(height: 16),
                          buildPreviewTextField(context, barcodeCtrl,
                              l10n.barcodeNumber, Icons.qr_code_scanner,
                              readOnly: widget.productToEdit != null),
                          const SizedBox(height: 16),
                          buildPreviewTextField(context, priceCtrl,
                              l10n.sellingPrice, Icons.attach_money,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          buildPreviewTextField(context, wholesalePriceCtrl,
                              l10n.wholesalePriceLabel, Icons.price_change,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          buildPreviewTextField(context, minPriceCtrl,
                              l10n.minPriceLabel2, Icons.price_change,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          buildPreviewTextField(context, qtyCtrl,
                              l10n.availableQty, Icons.inventory,
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          buildPreviewTextField(context, minQtyCtrl,
                              l10n.minStockLevel, Icons.trending_down,
                              keyboardType: TextInputType.number),
                        ],
                        const SizedBox(height: 16),
                        _buildCategoryDropdown(),
                      ],
                    ),
                  );
                },
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
                      child: Text(l10n.cancelBtn),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.productToEdit == null
                                    ? l10n.addProduct
                                    : l10n.saveChanges,
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

  Future<void> _pickImage() async {
    showPreviewAction(context);
  }

  Widget _buildImagePicker(AppLocalizations l10n) {
    final isArabic = l10n.localeName == 'ar';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: LayoutBuilder(builder: (context, size) {
        final image = AssetImageView(
          path: _selectedImagePath,
          width: 82,
          height: 82,
          borderRadius: 14,
          fallback: Container(
            color: AppColors.primaryColor.withOpacity(.1),
            alignment: Alignment.center,
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primaryColor,
              size: 32,
            ),
          ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'صورة المنتج' : 'Product image',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              isArabic
                  ? 'اختيارية وتظهر في المنتجات والمبيعات'
                  : 'Optional; shown in products and sales',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.mutedColor,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon:
                      const Icon(Icons.add_photo_alternate_outlined, size: 17),
                  label: Text(isArabic ? 'اختيار صورة' : 'Choose image'),
                ),
                if (_selectedImagePath != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedImagePath = null),
                    icon: const Icon(Icons.delete_outline, size: 17),
                    label: Text(isArabic ? 'إزالة' : 'Remove'),
                  ),
              ],
            ),
          ],
        );
        if (size.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.4) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [image, const SizedBox(height: 12), details]);
        }
        return Row(children: [
          image,
          const SizedBox(width: 14),
          Expanded(child: details)
        ]);
      }),
    );
  }

  Widget _buildCategoryDropdown() {
    final l10n = AppLocalizations.of(context);
    // Filter out "All" - it's only a UI filter, not a real category
    final validCategories = widget.categories.where((c) => c != 'All').toList();

    // Ensure selected category is valid
    if (selectedCategory == 'All' && validCategories.isNotEmpty) {
      selectedCategory = validCategories.first;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
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
        isExpanded: true,
        value: validCategories.contains(selectedCategory)
            ? selectedCategory
            : (validCategories.isNotEmpty ? validCategories.first : null),
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
          labelText: l10n.categoryLabel,
          prefixIcon: Icon(Icons.category, color: AppColors.primaryColor),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty || value == 'All') {
            return l10n.selectValidCategory;
          }
          return null;
        },
      ),
    );
  }
}
