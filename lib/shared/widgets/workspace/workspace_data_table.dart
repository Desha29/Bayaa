import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class WorkspaceColumn<T> {
  const WorkspaceColumn(
      {required this.label,
      required this.cell,
      this.numeric = false,
      this.compare});
  final String label;
  final Widget Function(T) cell;
  final bool numeric;
  final Comparator<T>? compare;
}

/// Local sorting and pagination are display state; records remain unchanged.
class WorkspaceDataTable<T> extends StatefulWidget {
  const WorkspaceDataTable(
      {super.key,
      required this.records,
      required this.columns,
      this.minimumWidth = 820,
      this.showViewToggle = true,
      this.emptyLabel,
      this.pageSize = 8});
  final List<T> records;
  final List<WorkspaceColumn<T>> columns;
  final double minimumWidth;
  final bool showViewToggle;
  final String? emptyLabel;
  final int pageSize;

  @override
  State<WorkspaceDataTable<T>> createState() => _WorkspaceDataTableState<T>();
}

class _WorkspaceDataTableState<T> extends State<WorkspaceDataTable<T>> {
  int _page = 0;
  int? _sortColumn;
  bool _ascending = true;
  bool? _preferCards;

  @override
  void didUpdateWidget(covariant WorkspaceDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final rows = List<T>.from(widget.records);
    final compare =
        _sortColumn == null ? null : widget.columns[_sortColumn!].compare;
    if (compare != null) {
      rows.sort((a, b) => _ascending ? compare(a, b) : compare(b, a));
    }
    final pages = math.max(1, (rows.length / widget.pageSize).ceil());
    final page = math.min(_page, pages - 1);
    final start = page * widget.pageSize;
    final visible = rows.skip(start).take(widget.pageSize).toList();
    return LayoutBuilder(builder: (context, constraints) {
      final cards = widget.showViewToggle &&
          (_preferCards ??
              (constraints.maxWidth < 600 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.4));
      return Container(
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor)),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (widget.showViewToggle) ...[
            Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 8, 4),
                child: Row(children: [
                  Expanded(
                      child: Text(
                          arabic
                              ? '${rows.length} سجل'
                              : '${rows.length} records',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.mutedColor))),
                  IconButton(
                      tooltip: arabic ? 'عرض البطاقات' : 'Card view',
                      isSelected: cards,
                      onPressed: () => setState(() => _preferCards = true),
                      icon: const Icon(Icons.grid_view_outlined, size: 20)),
                  IconButton(
                      tooltip: arabic ? 'عرض الجدول' : 'Table view',
                      isSelected: !cards,
                      onPressed: () => setState(() => _preferCards = false),
                      icon: const Icon(Icons.table_rows_outlined, size: 20)),
                ])),
            Divider(height: 1, color: AppColors.borderColor),
          ],
          if (rows.isEmpty)
            Padding(
                padding: const EdgeInsets.all(48),
                child: Text(widget.emptyLabel ??
                    (arabic
                        ? 'لا توجد نتائج تطابق البحث'
                        : 'No matching records')))
          else if (cards)
            _buildCards(context, visible, constraints.maxWidth)
          else
            LayoutBuilder(
                builder: (context, size) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth:
                                math.max(size.maxWidth, widget.minimumWidth)),
                        child: DataTable(
                          sortColumnIndex: _sortColumn,
                          sortAscending: _ascending,
                          horizontalMargin: 20,
                          columnSpacing: 28,
                          headingRowHeight: 46,
                          dataRowMinHeight: 68,
                          dataRowMaxHeight: 76,
                          headingRowColor:
                              WidgetStatePropertyAll(AppColors.primaryColor),
                          headingTextStyle: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryForeground),
                          dataTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.textPrimary),
                          dividerThickness: .7,
                          columns: [
                            for (var i = 0; i < widget.columns.length; i++)
                              DataColumn(
                                  label: Text(widget.columns[i].label),
                                  numeric: widget.columns[i].numeric,
                                  onSort: widget.columns[i].compare == null
                                      ? null
                                      : (index, ascending) => setState(() {
                                            _sortColumn = index;
                                            _ascending = ascending;
                                            _page = 0;
                                          }))
                          ],
                          rows: [
                            for (var i = 0; i < visible.length; i++)
                              DataRow(
                                  color: WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.hovered)
                                              ? AppColors.primaryColor
                                                  .withValues(alpha: .06)
                                              : (i.isOdd
                                                  ? AppColors.backgroundColor
                                                      .withValues(alpha: .45)
                                                  : AppColors.surfaceColor)),
                                  cells: [
                                    for (final column in widget.columns)
                                      DataCell(column.cell(visible[i]))
                                  ])
                          ],
                        ),
                      ),
                    )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderColor))),
            child: Row(children: [
              Expanded(
                  child: Text(
                      arabic
                          ? 'عرض ${rows.isEmpty ? 0 : start + 1}–${math.min(start + widget.pageSize, rows.length)} من ${rows.length}'
                          : 'Showing ${rows.isEmpty ? 0 : start + 1}–${math.min(start + widget.pageSize, rows.length)} of ${rows.length}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedColor,
                          fontSize: 11))),
              IconButton(
                  tooltip: arabic ? 'السابق' : 'Previous page',
                  onPressed:
                      page > 0 ? () => setState(() => _page = page - 1) : null,
                  icon: const BackButtonIcon()),
              Text('${page + 1} / $pages',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 11)),
              IconButton(
                  tooltip: arabic ? 'التالي' : 'Next page',
                  onPressed: page + 1 < pages
                      ? () => setState(() => _page = page + 1)
                      : null,
                  icon: const RotatedBox(
                      quarterTurns: 2, child: BackButtonIcon())),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _buildCards(
      BuildContext context, List<T> records, double availableWidth) {
    final columns = (availableWidth / 340).floor().clamp(1, 3);
    final cardWidth = (availableWidth - 24 - (columns - 1) * 12) / columns;
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(spacing: 12, runSpacing: 12, children: [
          for (final record in records)
            SizedBox(
                width: cardWidth,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var index = 0;
                            index < widget.columns.length;
                            index++) ...[
                          if (index > 0)
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                    height: 1,
                                    color: AppColors.borderColor
                                        .withValues(alpha: .6))),
                          Text(widget.columns[index].label,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: AppColors.mutedColor)),
                          const SizedBox(height: 5),
                          DefaultTextStyle(
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  fontWeight: index == 0
                                      ? FontWeight.w700
                                      : FontWeight.bold),
                              child: widget.columns[index].cell(record)),
                        ],
                      ]),
                )),
        ]));
  }
}
