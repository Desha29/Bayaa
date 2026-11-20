import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'erp_view_spec.dart';
import 'erp_status_badge.dart';
import 'erp_record_avatar.dart';
import 'erp_record_details_screen.dart';

class ErpRecordsView extends StatefulWidget {
  const ErpRecordsView({super.key, required this.spec, required this.records});
  final ErpViewSpec spec;
  final List<ErpRecordView> records;
  @override
  State<ErpRecordsView> createState() => _ErpRecordsViewState();
}

class _ErpRecordsViewState extends State<ErpRecordsView> {
  bool? _preferCards;
  ErpViewSpec get spec => widget.spec;
  List<ErpRecordView> get records => widget.records;
  void _open(BuildContext context, ErpRecordView record) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ErpRecordDetailsScreen(spec: spec, record: record)));

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    if (records.isEmpty) {
      return Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
              child: Column(children: [
            Icon(Icons.search_off_rounded,
                size: 44, color: AppColors.mutedColor),
            const SizedBox(height: 16),
            Text(arabic ? 'لا توجد نتائج مطابقة' : 'No matching records',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
                arabic
                    ? 'جرّب تغيير البحث أو الفلاتر'
                    : 'Try another search or filter',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.mutedColor)),
          ])));
    }
    return LayoutBuilder(builder: (context, constraints) {
      final cards = _preferCards ??
          (constraints.maxWidth < 900 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.4);
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
        ]),
        const SizedBox(height: 8),
        if (cards)
          _cards(context, constraints.maxWidth)
        else
          _table(context, constraints.maxWidth, arabic),
      ]);
    });
  }

  Widget _cards(BuildContext context, double availableWidth) {
    final isMobile = availableWidth < 600;
    final columns = isMobile ? 2 : (availableWidth / 350).floor().clamp(1, 3);
    final spacing = isMobile ? 10.0 : 14.0;
    final cardWidth = (availableWidth - (columns - 1) * spacing) / columns;
    return Wrap(spacing: spacing, runSpacing: spacing, children: [
      for (final record in records)
        SizedBox(
            width: cardWidth,
            child: Material(
              color: AppColors.surfaceColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AppColors.borderColor)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                  onTap: () => _open(context, record),
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 10 : 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            ErpRecordAvatar(
                                tag: '${spec.id}-${record.id}',
                                icon: spec.icon,
                                size: isMobile ? 32 : 40),
                            SizedBox(width: isMobile ? 8 : 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(record.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: isMobile ? 12 : 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(record.id,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 9.5 : 11,
                                          color: AppColors.mutedColor)),
                                ])),
                            if (!isMobile) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.chevron_right,
                                  textDirection: Directionality.of(context),
                                  color: AppColors.mutedColor),
                            ],
                          ]),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 8 : 14),
                              child: Divider(
                                  height: 1, color: AppColors.borderColor)),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            for (var index = 1;
                                index < spec.columns.length &&
                                    index < record.cells.length;
                                index++)
                              SizedBox(
                                  width: isMobile
                                      ? cardWidth - 24
                                      : (cardWidth < 330
                                          ? cardWidth - 32
                                          : (cardWidth - 48) / 2),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(spec.columns[index].of(context),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isMobile ? 9 : 10,
                                                color: AppColors.mutedColor)),
                                        const SizedBox(height: 2),
                                        Text(record.cells[index],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: isMobile ? 11 : 12,
                                                fontWeight: FontWeight.bold)),
                                      ])),
                          ]),
                          SizedBox(height: isMobile ? 10 : 16),
                          ErpStatusBadge(
                              label: record.status.of(context),
                              tone: record.tone),
                        ]),
                  )),
            )),
    ]);
  }

  Widget _table(BuildContext context, double width, bool arabic) => Container(
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: width),
              child: DataTable(
                headingRowColor: WidgetStatePropertyAll(AppColors.primaryColor),
                dataRowMinHeight: 72,
                dataRowMaxHeight: 86,
                columnSpacing: 28,
                showCheckboxColumn: false,
                columns: [
                  ...spec.columns.map(
                      (column) => DataColumn(label: Text(column.of(context)))),
                  DataColumn(label: Text(arabic ? 'الحالة' : 'Status')),
                  const DataColumn(label: SizedBox(width: 24)),
                ],
                rows: records
                    .map((record) => DataRow(
                            onSelectChanged: (_) => _open(context, record),
                            cells: [
                              for (var index = 0;
                                  index < spec.columns.length;
                                  index++)
                                DataCell(index == 0
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            ErpRecordAvatar(
                                                tag: '${spec.id}-${record.id}',
                                                icon: spec.icon,
                                                size: 36),
                                            const SizedBox(width: 10),
                                            Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      record.cells.isEmpty
                                                          ? record.title
                                                          : record.cells.first,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(height: 3),
                                                  Text(record.id,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 10,
                                                          color: AppColors
                                                              .mutedColor)),
                                                ]),
                                          ])
                                    : Text(record.cells.length > index
                                        ? record.cells[index]
                                        : '—')),
                              DataCell(ErpStatusBadge(
                                  label: record.status.of(context),
                                  tone: record.tone)),
                              DataCell(IconButton(
                                  tooltip:
                                      arabic ? 'عرض التفاصيل' : 'View details',
                                  icon:
                                      const Icon(Icons.arrow_forward, size: 18),
                                  onPressed: () => _open(context, record))),
                            ]))
                    .toList(),
              )),
        ),
      );
}
