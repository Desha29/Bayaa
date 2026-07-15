import 'package:flutter/material.dart';

import 'package:bayaa_pos/l10n/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../sales/data/models/sale_model.dart';
import '../../domain/refund_calculation_service.dart';

/// An item selected for refund.
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
    super.key,
    required this.originalSale,
    required this.refundService,
  });

  @override
  State<PartialRefundDialog> createState() => _PartialRefundDialogState();
}

class _PartialRefundDialogState extends State<PartialRefundDialog> {
  List<RefundableItem>? refundableItems;
  final Map<String, int> selectedQuantities = {};
  final Map<String, TextEditingController> controllers = {};
  final Map<String, String?> validationErrors = {};
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRefundableItems();
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRefundableItems() async {
    final result =
        await widget.refundService.getRefundableItems(widget.originalSale.id);

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        errorMessage = failure.message;
        loading = false;
      }),
      (items) => setState(() {
        refundableItems = items;
        loading = false;
        for (final item in items) {
          selectedQuantities[item.productId] = 0;
          controllers[item.productId] = TextEditingController();
          validationErrors[item.productId] = null;
        }
      }),
    );
  }

  double get totalRefundAmount {
    final items = refundableItems;
    if (items == null) return 0.0;

    return items.fold<double>(
      0.0,
      (total, item) =>
          total + item.unitPrice * (selectedQuantities[item.productId] ?? 0),
    );
  }

  bool get hasSelectedItems => selectedQuantities.values.any((qty) => qty > 0);

  bool get hasValidationErrors =>
      validationErrors.values.any((error) => error != null);

  List<RefundItem> get selectedRefundItems {
    final items = refundableItems;
    if (items == null) return [];

    return items
        .where((item) => (selectedQuantities[item.productId] ?? 0) > 0)
        .map(
          (item) => RefundItem(
            productId: item.productId,
            productName: item.productName,
            quantity: selectedQuantities[item.productId]!,
            unitPrice: item.unitPrice,
            wholesalePrice: item.wholesalePrice,
          ),
        )
        .toList();
  }

  String get _invoiceId => widget.originalSale.id.length > 8
      ? widget.originalSale.id.substring(0, 8)
      : widget.originalSale.id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 760),
        child: SizedBox(
          width: 960,
          child: Column(
            children: [
              _buildHeader(l10n),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? _buildErrorState()
                        : _buildItemsList(),
              ),
              _buildFooter(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.78),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.assignment_return_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.partialRefund,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.invoiceNumber(_invoiceId),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.cancelBtn,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 42, color: AppColors.errorColor),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalRefundAmount,
                    style: const TextStyle(
                      color: AppColors.mutedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${totalRefundAmount.toStringAsFixed(2)} ${l10n.currencyEg}',
                    style: const TextStyle(
                      color: AppColors.errorColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              foregroundColor: AppColors.kDarkChip,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.cancelBtn),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: hasSelectedItems && !hasValidationErrors
                ? _confirmRefund
                : null,
            icon: const Icon(Icons.assignment_return_outlined, size: 19),
            label: Text(l10n.confirmRefund),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              backgroundColor: AppColors.errorColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              disabledForegroundColor: Colors.grey.shade500,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final l10n = AppLocalizations.of(context);
    if (refundableItems == null || refundableItems!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 44, color: AppColors.mutedColor),
            const SizedBox(height: 12),
            Text(l10n.noRefundableProducts),
          ],
        ),
      );
    }

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.grey.withOpacity(0.14),
            ),
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 26,
              headingRowHeight: 56,
              dataRowMinHeight: 68,
              dataRowMaxHeight: 76,
              headingRowColor: WidgetStatePropertyAll(
                AppColors.primaryColor.withOpacity(0.07),
              ),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.kDarkChip,
                fontSize: 13,
              ),
              dataTextStyle: const TextStyle(
                color: AppColors.kDarkChip,
                fontSize: 13,
              ),
              columns: [
                DataColumn(label: Text(l10n.productColumn)),
                DataColumn(label: Text(l10n.soldQty), numeric: true),
                DataColumn(label: Text(l10n.alreadyRefunded), numeric: true),
                DataColumn(label: Text(l10n.remaining), numeric: true),
                DataColumn(label: Text(l10n.priceColumn), numeric: true),
                DataColumn(label: Text(l10n.refundQty), numeric: true),
                DataColumn(label: Text(l10n.totalColumn), numeric: true),
              ],
              rows: refundableItems!.map(_buildItemRow).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildItemRow(RefundableItem item) {
    final l10n = AppLocalizations.of(context);
    final selectedQty = selectedQuantities[item.productId] ?? 0;
    final hasSelection = selectedQty > 0;
    final subtotal = item.unitPrice * selectedQty;

    return DataRow(
      color: WidgetStateProperty.resolveWith(
        (_) => hasSelection ? AppColors.errorColor.withOpacity(0.035) : null,
      ),
      cells: [
        DataCell(
          SizedBox(
            width: 220,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        DataCell(_numberText(item.originalQuantity)),
        DataCell(
          _numberText(
            item.refundedQuantity,
            color: item.refundedQuantity > 0
                ? AppColors.errorColor
                : AppColors.mutedColor,
          ),
        ),
        DataCell(
          _numberText(
            item.remainingQuantity,
            color: item.canBeRefunded
                ? AppColors.successColor
                : AppColors.mutedColor,
            bold: true,
          ),
        ),
        DataCell(Text(item.unitPrice.toStringAsFixed(2))),
        DataCell(
          SizedBox(
            width: 86,
            child: TextField(
              controller: controllers[item.productId],
              enabled: item.canBeRefunded,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: '0',
                errorText: validationErrors[item.productId],
                errorStyle: const TextStyle(fontSize: 10),
                isDense: true,
                filled: true,
                fillColor: item.canBeRefunded
                    ? Colors.white
                    : Colors.grey.withOpacity(0.08),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: validationErrors[item.productId] != null
                        ? AppColors.errorColor
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _updateRefundQuantity(item, value, l10n),
            ),
          ),
        ),
        DataCell(
          Text(
            '${subtotal.toStringAsFixed(2)} ${l10n.currencyEg}',
            style: TextStyle(
              color: hasSelection ? AppColors.errorColor : AppColors.mutedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _numberText(int value, {Color? color, bool bold = false}) {
    return Text(
      '$value',
      style: TextStyle(
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  void _updateRefundQuantity(
    RefundableItem item,
    String value,
    AppLocalizations l10n,
  ) {
    setState(() {
      if (value.isEmpty) {
        selectedQuantities[item.productId] = 0;
        validationErrors[item.productId] = null;
        return;
      }

      final quantity = int.tryParse(value);
      if (quantity == null) {
        validationErrors[item.productId] = l10n.invalidNumber;
        selectedQuantities[item.productId] = 0;
      } else if (quantity < 0) {
        validationErrors[item.productId] = l10n.cannotBeNegative;
        selectedQuantities[item.productId] = 0;
      } else if (quantity > item.remainingQuantity) {
        validationErrors[item.productId] =
            l10n.maxLimit(item.remainingQuantity);
        selectedQuantities[item.productId] = 0;
      } else {
        selectedQuantities[item.productId] = quantity;
        validationErrors[item.productId] = null;
      }
    });
  }

  void _confirmRefund() {
    if (!_validateAllQuantities()) return;
    Navigator.of(context).pop(selectedRefundItems);
  }

  bool _validateAllQuantities() {
    final items = refundableItems;
    if (items == null) return false;

    var isValid = true;
    setState(() {
      for (final item in items) {
        final enteredValue = controllers[item.productId]?.text.trim() ?? '';
        if (enteredValue.isEmpty) {
          selectedQuantities[item.productId] = 0;
          validationErrors[item.productId] = null;
          continue;
        }

        final quantity = int.tryParse(enteredValue);
        if (quantity == null) {
          validationErrors[item.productId] =
              AppLocalizations.of(context).invalidNumber;
          selectedQuantities[item.productId] = 0;
          isValid = false;
        } else if (quantity < 0) {
          validationErrors[item.productId] =
              AppLocalizations.of(context).cannotBeNegative;
          selectedQuantities[item.productId] = 0;
          isValid = false;
        } else if (quantity > item.remainingQuantity) {
          validationErrors[item.productId] =
              AppLocalizations.of(context).maxLimit(item.remainingQuantity);
          selectedQuantities[item.productId] = 0;
          isValid = false;
        } else {
          selectedQuantities[item.productId] = quantity;
          validationErrors[item.productId] = null;
        }
      }
    });

    return isValid && hasSelectedItems;
  }
}
