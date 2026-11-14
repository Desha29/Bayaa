import 'package:flutter/material.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class ProductsFilterSection extends StatelessWidget {
  const ProductsFilterSection(
      {super.key,
      required this.searchController,
      required this.categoryFilter,
      required this.availabilityFilter,
      required this.categories,
      required this.availabilities,
      required this.onCategoryChanged,
      required this.onAvailabilityChanged,
      required this.onAddPressed,
      required this.onSearchChanged,
      required this.productCount,
      required this.isTableView,
      required this.onViewToggle,
      required this.onClearAll,
      this.focusNode});
  final TextEditingController searchController;
  final FocusNode? focusNode;
  final String? categoryFilter, availabilityFilter;
  final List<String> categories, availabilities;
  final ValueChanged<String> onCategoryChanged, onAvailabilityChanged;
  final VoidCallback onAddPressed, onSearchChanged, onClearAll;
  final int productCount;
  final bool isTableView;
  final ValueChanged<bool> onViewToggle;
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor)),
        child: LayoutBuilder(
            builder: (context, size) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(
                                width: size.maxWidth >= 700
                                    ? size.maxWidth - 190
                                    : size.maxWidth,
                                child: ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: searchController,
                                    builder: (context, value, _) => TextField(
                                        controller: searchController,
                                        focusNode: focusNode,
                                        onChanged: (_) => onSearchChanged(),
                                        decoration: InputDecoration(
                                            hintText: ar
                                                ? 'ابحث باسم المنتج أو الباركود...'
                                                : 'Search products by name or barcode...',
                                            prefixIcon: const Icon(Icons.search,
                                                size: 20),
                                            suffixIcon: value.text.isEmpty
                                                ? null
                                                : IconButton(
                                                    tooltip: ar
                                                        ? 'مسح البحث'
                                                        : 'Clear search',
                                                    icon: const Icon(
                                                        Icons.close,
                                                        size: 18),
                                                    onPressed: () {
                                                      searchController.clear();
                                                      onSearchChanged();
                                                      focusNode?.requestFocus();
                                                    }))))),
                            FilledButton.icon(
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accentColor,
                                    foregroundColor: AppColors.accentForeground,
                                    minimumSize: const Size(166, 48)),
                                onPressed: onAddPressed,
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(ar ? 'إضافة منتج' : 'Add product')),
                          ]),
                      const SizedBox(height: 14),
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (final e in [
                              ('*', l.all),
                              ('available', l.available),
                              ('lowStock', l.lowStock),
                              ('outOfStock', l.outOfStock)
                            ])
                              ChoiceChip(
                                  label: Text(e.$2),
                                  selected: (availabilityFilter ?? '*') == e.$1,
                                  selectedColor: AppColors.primaryColor,
                                  labelStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (availabilityFilter ?? '*') == e.$1
                                          ? AppColors.primaryForeground
                                          : AppColors.textSecondary),
                                  onSelected: (_) =>
                                      onAvailabilityChanged(e.$1)),
                            SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String>(
                                    key: ValueKey(categoryFilter),
                                    initialValue:
                                        categories.contains(categoryFilter)
                                            ? categoryFilter
                                            : null,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                        labelText: l.category, isDense: true),
                                    items: categories
                                        .map((v) => DropdownMenuItem(
                                            value: v,
                                            child: Text(v,
                                                overflow:
                                                    TextOverflow.ellipsis)))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) onCategoryChanged(v);
                                    })),
                            TextButton.icon(
                                onPressed: onClearAll,
                                icon: const Icon(Icons.restart_alt, size: 17),
                                label: Text(ar ? 'إعادة تعيين' : 'Reset')),
                          ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                            child: Text(
                                ar
                                    ? '$productCount منتج'
                                    : '$productCount products',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mutedColor,
                                    fontSize: 12))),
                        IconButton(
                            tooltip: ar ? 'عرض البطاقات' : 'Card view',
                            isSelected: !isTableView,
                            onPressed: () => onViewToggle(false),
                            icon:
                                const Icon(Icons.grid_view_rounded, size: 20)),
                        if (size.maxWidth >= 560)
                          IconButton(
                              tooltip: ar ? 'عرض الجدول' : 'Table view',
                              isSelected: isTableView,
                              onPressed: () => onViewToggle(true),
                              icon: const Icon(Icons.view_list_rounded,
                                  size: 21)),
                      ]),
                    ])));
  }
}
