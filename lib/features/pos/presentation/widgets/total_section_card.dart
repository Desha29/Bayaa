import 'package:flutter/material.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class TotalSectionCard extends StatelessWidget {
  const TotalSectionCard(
      {super.key,
      required this.totalAmount,
      required this.itemCount,
      this.onCheckout,
      this.onClearCart});
  final double totalAmount;
  final int itemCount;
  final VoidCallback? onCheckout, onClearCart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(
                    child: Text(l10n.invoiceSummaryTitle,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textPrimary))),
                Text(l10n.itemCountValue(itemCount),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.mutedColor))
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Text(l10n.grandTotalLabel,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.mutedColor))),
                Flexible(
                    child: Text(
                        '${totalAmount.toStringAsFixed(2)} ${l10n.currencyEg}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryColor)))
              ]),
              const SizedBox(height: 14),
              FilledButton.icon(
                  onPressed: itemCount == 0 ? null : onCheckout,
                  icon: const Icon(Icons.payments_outlined, size: 19),
                  label: Text(l10n.checkoutBtn,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: AppColors.accentForeground,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 4),
              TextButton.icon(
                  onPressed: itemCount == 0 ? null : onClearCart,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: Text(l10n.clearCartBtn,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 11)),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.mutedColor,
                      minimumSize: const Size(0, 32))),
            ]));
  }
}
