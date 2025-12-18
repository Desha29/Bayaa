import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../sales/data/models/sale_model.dart';
import '../../domain/refund_calculation_service.dart';

/// Item to refund with selected quantity
class RefundItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double wholesalePrice;

  RefundItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.wholesalePrice,
  });

  double get total => unitPrice * quantity;
}

class PartialRefundDialog extends StatefulWidget {
  final Sale originalSale;
  final RefundCalculationService refundService;

  const PartialRefundDialog({
    Key? key,
    required this.originalSale,
    required this.refundService,
  }) : super(key: key);

  @override
  State<PartialRefundDialog> createState() => _PartialRefundDialogState();
}

class _PartialRefundDialogState extends State<PartialRefundDialog> {
  List<RefundableItem>? refundableItems;
  Map<String, int> selectedQuantities = {};
  Map<String, TextEditingController> controllers = {};
  Map<String, String?> validationErrors = {};
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRefundableItems();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRefundableItems() async {
    final result = await widget.refundService.getRefundableItems(widget.originalSale.id);
    
    result.fold(
      (failure) {
        setState(() {
          errorMessage = failure.message;
          loading = false;
        });
      },
      (items) {
        setState(() {
          refundableItems = items;
          loading = false;
          // Initialize selected quantities and controllers
          for (var item in items) {
            selectedQuantities[item.productId] = 0;
            controllers[item.productId] = TextEditingController();
            validationErrors[item.productId] = null;
          }
        });
      },
    );
  }

  double get totalRefundAmount {
    if (refundableItems == null) return 0;
    double total = 0;
    for (var item in refundableItems!) {
      final quantity = selectedQuantities[item.productId] ?? 0;
      total += item.unitPrice * quantity;
    }
    return total;
  }

  bool get hasSelectedItems {
    return selectedQuantities.values.any((qty) => qty > 0);
  }

  List<RefundItem> get selectedRefundItems {
    if (refundableItems == null) return [];
    
    return refundableItems!
        .where((item) => (selectedQuantities[item.productId] ?? 0) > 0)
        .map((item) => RefundItem(
              productId: item.productId,
              productName: item.productName,
              quantity: selectedQuantities[item.productId]!,
              unitPrice: item.unitPrice,
              wholesalePrice: item.wholesalePrice,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.assignment_return, color: AppColors.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'استرجاع جزئي',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.kDarkChip,
                          ),
                        ),
                        Text(
                          'فاتورة #${widget.originalSale.id.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: AppColors.errorColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _buildItemsList(),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إجمالي المبلغ المسترجع:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kDarkChip,
                        ),
                      ),
                      Text(
                        '${totalRefundAmount.toStringAsFixed(2)} ج.م',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: hasSelectedItems
                              ? () => Navigator.of(context).pop(selectedRefundItems)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('تأكيد الاسترجاع'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    if (refundableItems == null || refundableItems!.isEmpty) {
      return const Center(
        child: Text('لا توجد منتجات قابلة للاسترجاع'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.grey.withOpacity(0.1),
        ),
        child: DataTable(
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.kDarkChip,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(
            color: AppColors.kDarkChip,
            fontSize: 13,
          ),
          columnSpacing: 20,
          columns: const [
            DataColumn(label: Text('المنتج')),
            DataColumn(label: Text('الكمية المباعة'), numeric: true),
            DataColumn(label: Text('تم استرجاعه'), numeric: true),
            DataColumn(label: Text('المتبقي'), numeric: true),
            DataColumn(label: Text('السعر'), numeric: true),
            DataColumn(label: Text('الكمية المسترجعة'), numeric: true),
            DataColumn(label: Text('الإجمالي'), numeric: true),
          ],
          rows: refundableItems!.map((item) {
            final selectedQty = selectedQuantities[item.productId] ?? 0;
            final subtotal = item.unitPrice * selectedQty;
            
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          item.productName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text('${item.originalQuantity}')),
                DataCell(
                  Text(
                    '${item.refundedQuantity}',
                    style: TextStyle(
                      color: item.refundedQuantity > 0
                          ? AppColors.errorColor
                          : AppColors.mutedColor,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${item.remainingQuantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.canBeRefunded
                          ? AppColors.successColor
                          : AppColors.mutedColor,
                    ),
                  ),
                ),
                DataCell(Text('${item.unitPrice.toStringAsFixed(2)}')),
                DataCell(
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: controllers[item.productId],
                      enabled: item.canBeRefunded,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '0',
                        errorText: validationErrors[item.productId],
                        errorStyle: const TextStyle(fontSize: 10),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: validationErrors[item.productId] != null
                                ? AppColors.errorColor
                                : Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: validationErrors[item.productId] != null
                                ? AppColors.errorColor
                                : Colors.grey.shade400,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: validationErrors[item.productId] != null
                                ? AppColors.errorColor
                                : AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            selectedQuantities[item.productId] = 0;
                            validationErrors[item.productId] = null;
                          });
                          return;
                        }

                        final qty = int.tryParse(value);
                        
                        if (qty == null) {
                          setState(() {
                            validationErrors[item.productId] = 'رقم غير صالح';
                            selectedQuantities[item.productId] = 0;
                          });
                        } else if (qty < 0) {
                          setState(() {
                            validationErrors[item.productId] = 'لا يمكن أن يكون سالب';
                            selectedQuantities[item.productId] = 0;
                          });
                        } else if (qty > item.remainingQuantity) {
                          setState(() {
                            validationErrors[item.productId] = 
                                'الحد الأقصى: ${item.remainingQuantity}';
                            selectedQuantities[item.productId] = 0;
                          });
                        } else {
                          setState(() {
                            selectedQuantities[item.productId] = qty;
                            validationErrors[item.productId] = null;
                          });
                        }
                      },
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${subtotal.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedQty > 0
                          ? AppColors.errorColor
                          : AppColors.mutedColor,
                    ),
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
