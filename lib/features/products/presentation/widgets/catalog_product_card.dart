import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import '../models/product_view_data.dart';

enum _ProductAction { edit, delete }

class CatalogProductCard extends StatelessWidget {
  const CatalogProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.statusColor,
    required this.statusText,
  });

  final ProductViewData product;
  final VoidCallback onDelete, onEdit;
  final Color statusColor;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    return Material(
      color: AppColors.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 84,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: AppColors.backgroundColor,
                  child: Center(
                    child: AssetImageView(
                      path: product.imagePath,
                      width: 132,
                      height: 72,
                      borderRadius: 8,
                      fit: BoxFit.contain,
                      fallback: Icon(Icons.inventory_2_outlined,
                          size: 30, color: AppColors.mutedColor),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  start: 8,
                  end: 54,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child:
                          WorkspacePill(label: statusText, color: statusColor),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 4,
                  end: 4,
                  child: PopupMenuButton<_ProductAction>(
                    tooltip: ar ? 'خيارات المنتج' : 'Product actions',
                    iconSize: 19,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceColor,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (action) => switch (action) {
                      _ProductAction.edit => onEdit(),
                      _ProductAction.delete => onDelete(),
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _ProductAction.edit,
                        child: Row(children: [
                          Icon(Icons.edit_outlined,
                              size: 18, color: AppColors.primaryColor),
                          const SizedBox(width: 10),
                          Expanded(child: Text(l.edit)),
                        ]),
                      ),
                      PopupMenuItem(
                        value: _ProductAction.delete,
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              size: 18, color: AppColors.errorColor),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(l.delete,
                                  style:
                                      TextStyle(color: AppColors.errorColor))),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              primary: false,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.secondaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  Tooltip(
                    message: product.name,
                    child: Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 4),
                  Text('${product.price.toStringAsFixed(2)} ${l.currencyEg}',
                      style: TextStyle(
                          fontSize: 17,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l.barcode,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mutedColor)),
                      Text(product.barcode,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _detailsRow(
                    (l.quantity, '${product.quantity}'),
                    (
                      ar ? 'حد المخزون' : 'Min. stock',
                      '${product.minQuantity}'
                    ),
                  ),
                  const SizedBox(height: 5),
                  _detailsRow(
                    (
                      l.wholesalePrice,
                      product.wholesalePrice.toStringAsFixed(2)
                    ),
                    (l.minPriceColumn, product.minPrice.toStringAsFixed(2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsRow((String, String) first, (String, String) second) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _ProductFact(label: first.$1, value: first.$2)),
          const SizedBox(width: 5),
          Expanded(child: _ProductFact(label: second.$1, value: second.$2)),
        ],
      );
}

class _ProductFact extends StatelessWidget {
  const _ProductFact({required this.label, required this.value});

  final String label, value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tooltip(
              message: label,
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mutedColor)),
            ),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
      );
}
