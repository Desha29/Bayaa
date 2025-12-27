import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// HID suppression handled by SalesScreen via focus checks; don't directly
// remove global listeners from widgets.
import '../../../../core/constants/app_colors.dart';

class CartItemRow extends StatefulWidget {
  final String name;
  final String id;
  final double price;
  final int quantity;
  final int remainingQuantity;
  final DateTime date;
  final double minPrice;
  final VoidCallback? onRemove;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final Function(double)? onEditPrice;

  const CartItemRow({
    super.key,
    required this.name,
    required this.id,
    required this.price,
    required this.quantity,
    required this.remainingQuantity,
    required this.date,
    required this.minPrice,
    this.onRemove,
    this.onIncrease,
    this.onDecrease,
    this.onEditPrice,
  });

  @override
  State<CartItemRow> createState() => _CartItemRowState();
}

class _CartItemRowState extends State<CartItemRow> {
  bool _isEditingPrice = false;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController =
        TextEditingController(text: widget.price.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _showEditPriceDialog() async {
    _priceController.text = widget.price.toStringAsFixed(2);

    // Rely on focus-based suppression in SalesScreen; do not remove global listeners here.

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل السعر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الحد الأدنى للسعر: ${widget.minPrice.toStringAsFixed(2)} ج.م',
                style: TextStyle(
                  color: AppColors.warningColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                // Allow progressive typing: empty, integers, or decimals up to 2 places.
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
                decoration: InputDecoration(
                  labelText: 'السعر الجديد',
                  suffixText: 'ج.م',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.surfaceColor,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(_priceController.text);
                if (newPrice != null && newPrice >= widget.minPrice) {
                  widget.onEditPrice?.call(newPrice);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'السعر يجب أن يكون أكبر من أو يساوي ${widget.minPrice.toStringAsFixed(2)} ج.م',
                      ),
                      backgroundColor: AppColors.kDangerRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimaryBlue,
              ),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    // No-op: HID listener reattachment handled centrally by SalesScreen focus logic.
  }

  // Get color for remaining quantity indicator
  Color _getRemainingQuantityColor() {
    if (widget.remainingQuantity <= 5) {
      return AppColors.kDangerRed;
    } else if (widget.remainingQuantity <= 20) {
      return AppColors.warningColor;
    } else {
      return AppColors.kSuccessGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.price * widget.quantity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Row(
            children: [
              Expanded(
                flex: isWide ? 4 : 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.name} (كود: ${widget.id})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'تاريخ: ${widget.date.year}/${widget.date.month}/${widget.date.day}',
                          style: TextStyle(
                            color: AppColors.mutedColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Remaining quantity indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                _getRemainingQuantityColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  _getRemainingQuantityColor().withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 12,
                                color: _getRemainingQuantityColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'متبقي: ${widget.remainingQuantity}',
                                style: TextStyle(
                                  color: _getRemainingQuantityColor(),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isWide) const SizedBox(width: 12),
              Expanded(
                flex: isWide ? 2 : 2,
                child: GestureDetector(
                  onTap: _showEditPriceDialog,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.price.toStringAsFixed(0)} ج.م',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 14,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: isWide ? 3 : 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQtyButton(Icons.remove, widget.onDecrease),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${widget.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildQtyButton(Icons.add, widget.onIncrease),
                  ],
                ),
              ),
              if (isWide) const SizedBox(width: 12),
              Expanded(
                flex: isWide ? 2 : 2,
                child: Text(
                  '${total.toStringAsFixed(0)} ج.م',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: widget.onRemove ?? () {},
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.kDangerRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed ?? () {},
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Icon(icon, size: 16, color: AppColors.secondaryColor),
      ),
    );
  }
}
