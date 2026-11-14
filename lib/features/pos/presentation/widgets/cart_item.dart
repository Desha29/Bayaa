import 'package:flutter/material.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class CartItemRow extends StatelessWidget {
  const CartItemRow(
      {super.key,
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
      this.onEditPrice});
  final String name, id;
  final double price, minPrice;
  final int quantity, remainingQuantity;
  final DateTime date;
  final VoidCallback? onRemove, onIncrease, onDecrease;
  final ValueChanged<double>? onEditPrice;

  Future<void> _editPrice(BuildContext context) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) => _PriceEditorDialog(price: price),
    );
    if (result != null) onEditPrice?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = l10n.localeName == 'ar';
    return Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.inventory_2_outlined,
                    size: 18, color: AppColors.secondaryColor)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(id,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: AppColors.mutedColor)),
                ])),
            IconButton(
                tooltip: ar ? 'إزالة من الفاتورة' : 'Remove from order',
                onPressed: onRemove,
                icon: Icon(Icons.close_rounded,
                    size: 17, color: AppColors.mutedColor),
                visualDensity: VisualDensity.compact),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Material(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                    onTap: () => _editPrice(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 8),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(price.toStringAsFixed(2),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const SizedBox(width: 5),
                          Icon(Icons.edit_outlined,
                              size: 13, color: AppColors.mutedColor),
                        ])))),
            const Spacer(),
            _quantityButton(ar ? 'تقليل الكمية' : 'Decrease quantity',
                Icons.remove_rounded, onDecrease),
            SizedBox(
                width: 28,
                child: Text('$quantity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary))),
            _quantityButton(ar ? 'زيادة الكمية' : 'Increase quantity',
                Icons.add_rounded, onIncrease),
            const SizedBox(width: 10),
            Flexible(
                child: Text(
                    '${(price * quantity).toStringAsFixed(2)} ${l10n.currencyEg}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor))),
          ]),
        ]));
  }

  Widget _quantityButton(String label, IconData icon, VoidCallback? action) =>
      SizedBox.square(
          dimension: 32,
          child: IconButton(
              tooltip: label,
              onPressed: action,
              style: IconButton.styleFrom(
                  backgroundColor:
                      AppColors.secondaryColor.withValues(alpha: .06),
                  foregroundColor: AppColors.secondaryColor,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7))),
              icon: Icon(icon, size: 17)));
}

class _PriceEditorDialog extends StatefulWidget {
  const _PriceEditorDialog({required this.price});
  final double price;
  @override
  State<_PriceEditorDialog> createState() => _PriceEditorDialogState();
}

class _PriceEditorDialogState extends State<_PriceEditorDialog> {
  late final _controller =
      TextEditingController(text: widget.price.toStringAsFixed(2));
  bool _invalid = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text);
    if (value == null || value < 0) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = l10n.localeName == 'ar';
    return AlertDialog(
      title: Text(l10n.editPriceTitle),
      content: TextField(
          controller: _controller,
          autofocus: true,
          onSubmitted: (_) => _submit(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              labelText: l10n.newPriceLabel,
              suffixText: l10n.currencyEg,
              errorText: _invalid
                  ? (ar ? 'أدخل سعراً صحيحاً' : 'Enter a valid price')
                  : null)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelBtn)),
        FilledButton(onPressed: _submit, child: Text(l10n.saveBtn)),
      ],
    );
  }
}
