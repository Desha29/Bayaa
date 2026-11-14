import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:flutter/material.dart';

class StockAlertCard extends StatelessWidget {
  const StockAlertCard({super.key, required this.product, this.onRestock});
  final ProductViewData product;
  final VoidCallback? onRestock;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    final out = product.quantity == 0;
    final tone = out ? AppColors.errorColor : AppColors.warningColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AssetImageView(
              path: product.imagePath,
              width: 48,
              height: 48,
              fallback: ColoredBox(
                  color: AppColors.backgroundColor,
                  child: Icon(Icons.inventory_2_outlined, color: tone))),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(product.name,
                    style: Theme.of(context).textTheme.titleMedium),
                Text('${product.category} · ${product.barcode}',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.mutedColor)),
              ])),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          WorkspacePill(
              label: out ? l.outOfStock : l.lowStock,
              color: tone,
              icon: Icons.warning_amber_rounded),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 18, runSpacing: 8, children: [
          _Fact(ar ? 'المتاح' : 'On hand', '${product.quantity}', tone),
          _Fact(ar ? 'الحد الأدنى' : 'Minimum', '${product.minQuantity}',
              AppColors.textPrimary),
          _Fact(
              ar ? 'سعر البيع' : 'Retail price',
              '${product.price.toStringAsFixed(2)} ${l.currencyEg}',
              AppColors.textPrimary),
        ]),
        if (onRestock != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
              onPressed: onRestock,
              icon: const Icon(Icons.add_box_outlined, size: 18),
              label: Text(l.restock)),
        ],
      ]),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value, this.color);
  final String label, value;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.mutedColor)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ]);
}
