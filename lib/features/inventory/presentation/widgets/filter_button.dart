import 'package:flutter/material.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class FilterButtonsWidget extends StatelessWidget {
  const FilterButtonsWidget(
      {super.key,
      required this.filter,
      required this.totalCount,
      required this.lowStockCount,
      required this.outOfStockCount,
      required this.onFilterChanged});
  final String filter;
  final int totalCount, lowStockCount, outOfStockCount;
  final ValueChanged<String> onFilterChanged;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final e in [
        ('all', l.all, totalCount),
        ('low', l.lowStock, lowStockCount),
        ('out', l.outOfStock, outOfStockCount)
      ])
        ChoiceChip(
            label: Text('${e.$2} (${e.$3})'),
            selected: filter == e.$1,
            onSelected: (_) => onFilterChanged(e.$1),
            selectedColor: AppColors.primaryColor,
            labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: filter == e.$1
                    ? AppColors.primaryForeground
                    : AppColors.textPrimary)),
    ]);
  }
}
