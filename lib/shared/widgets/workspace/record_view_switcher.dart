import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

/// Retains existing table cells and callbacks in an adaptive card alternative.
class RecordViewSwitcher extends StatefulWidget {
  const RecordViewSwitcher(
      {super.key, required this.table, this.cardViewBuilder});
  final DataTable table;

  /// Feature-owned compact cards can reuse the same view controls and viewport.
  final WidgetBuilder? cardViewBuilder;
  @override
  State<RecordViewSwitcher> createState() => _RecordViewSwitcherState();
}

class _RecordViewSwitcherState extends State<RecordViewSwitcher> {
  bool _cards = false;
  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return LayoutBuilder(
        builder: (context, size) => Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                    tooltip: ar ? 'عرض البطاقات' : 'Card view',
                    isSelected: _cards,
                    onPressed: () => setState(() => _cards = true),
                    icon: const Icon(Icons.grid_view_outlined, size: 20)),
                IconButton(
                    tooltip: ar ? 'عرض الجدول' : 'Table view',
                    isSelected: !_cards,
                    onPressed: () => setState(() => _cards = false),
                    icon: const Icon(Icons.table_rows_outlined, size: 20)),
              ]),
              Expanded(
                  child: _cards || size.maxWidth < 600
                      ? widget.cardViewBuilder != null
                          ? Builder(builder: widget.cardViewBuilder!)
                          : ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount: widget.table.rows.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final row = widget.table.rows[index];
                                return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: AppColors.surfaceColor,
                                        border: Border.all(
                                            color: AppColors.borderColor),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Column(children: [
                                      for (var i = 0; i < row.cells.length; i++)
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: DefaultTextStyle(
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 11,
                                                              color: AppColors
                                                                  .mutedColor),
                                                          child: widget
                                                              .table
                                                              .columns[i]
                                                              .label)),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                      flex: 3,
                                                      child: InkWell(
                                                          onTap: row
                                                              .cells[i].onTap,
                                                          child: row
                                                              .cells[i].child)),
                                                ]))
                                    ]));
                              })
                      : widget.table),
            ]));
  }
}
