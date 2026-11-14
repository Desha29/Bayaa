import 'package:flutter/material.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_data_table.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

class ProductTableView extends StatelessWidget {
  const ProductTableView(
      {super.key,
      required this.products,
      required this.onDelete,
      required this.onEdit,
      required this.statusColorFn,
      required this.statusTextFn,
      this.isManager = false});
  final List<ProductViewData> products;
  final ValueChanged<ProductViewData> onDelete, onEdit;
  final Color Function(int, int) statusColorFn;
  final String Function(int, int) statusTextFn;
  final bool isManager;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return WorkspaceDataTable<ProductViewData>(
        showViewToggle: false,
        records: products,
        columns: [
          WorkspaceColumn(
              label: l.productName,
              compare: (a, b) => a.name.compareTo(b.name),
              cell: (p) => SizedBox(
                  width: 210,
                  child: Row(children: [
                    AssetImageView(
                        fallback: Icon(Icons.inventory_2_outlined,
                            color: AppColors.primaryColor),
                        path: p.imagePath,
                        width: 38,
                        height: 38,
                        borderRadius: 8),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          Text(p.barcode,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: AppColors.mutedColor))
                        ]))
                  ]))),
          WorkspaceColumn(label: l.category, cell: (p) => Text(p.category)),
          WorkspaceColumn(
              label: l.price,
              numeric: true,
              compare: (a, b) => a.price.compareTo(b.price),
              cell: (p) => Text('${p.price.toStringAsFixed(2)} ${l.currencyEg}',
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          WorkspaceColumn(
              label: l.quantity,
              numeric: true,
              compare: (a, b) => a.quantity.compareTo(b.quantity),
              cell: (p) => Text('${p.quantity}')),
          WorkspaceColumn(
              label: l.status,
              cell: (p) => WorkspacePill(
                  label: statusTextFn(p.quantity, p.minQuantity),
                  color: statusColorFn(p.quantity, p.minQuantity))),
          WorkspaceColumn(
              label: l.actions,
              cell: (p) => Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        tooltip: l.edit,
                        onPressed: () => onEdit(p),
                        icon: const Icon(Icons.edit_outlined, size: 18)),
                    if (isManager)
                      IconButton(
                          tooltip: l.delete,
                          onPressed: () => onDelete(p),
                          icon: Icon(Icons.delete_outline,
                              size: 18, color: AppColors.errorColor))
                  ])),
        ]);
  }
}
