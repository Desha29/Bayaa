import 'package:bayaa_pos/shared/widgets/workspace/workspace_panel.dart';
import 'package:bayaa_pos/shared/widgets/charts/workspace_donut.dart';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/analytics_snapshot.dart';
import '../widgets/report_charts.dart';

enum _ReportArea {
  overview('Overview', 'نظرة عامة', Icons.dashboard_outlined),
  sales('Sales & invoices', 'المبيعات والفواتير', Icons.receipt_long_outlined),
  inventory('Inventory', 'المخزون', Icons.inventory_2_outlined),
  purchasing('Purchasing', 'المشتريات', Icons.local_shipping_outlined),
  finance('Finance', 'المالية', Icons.account_balance_outlined),
  operations('Operations', 'التشغيل', Icons.groups_outlined);

  const _ReportArea(this.en, this.ar, this.icon);
  final String en, ar;
  final IconData icon;
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  _ReportArea _area = _ReportArea.overview;
  int _days = 30;
  DateTimeRange? _custom;

  DateTimeRange get _range {
    final today = DateUtils.dateOnly(DateTime.now());
    return _custom ??
        DateTimeRange(
          start: DateTime(today.year, today.month, today.day - _days + 1),
          end: today,
        );
  }

  Future<void> _pickDates() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _range,
    );
    if (mounted && selected != null) setState(() => _custom = selected);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: BranchPreviewController.instance,
        builder: (context, _) {
          final locale = Localizations.localeOf(context);
          final ar = locale.languageCode == 'ar';
          final range = _range;
          final date = DateFormat.yMMMd(locale.toString());
          final snapshot = AnalyticsSnapshot(range);
          final branch = BranchPreviewController.instance;
          final number = NumberFormat.decimalPattern(locale.toString());
          final currency = NumberFormat.decimalPatternDigits(
              locale: locale.toString(), decimalDigits: 2);
          String tr(String en, String arabic) => ar ? arabic : en;
          String money(double value) =>
              '${currency.format(value)} ${tr('EGP', 'ج.م.')}';
          String count(double value) => number.format(value);
          final empty =
              tr('No data in this selection.', 'لا توجد بيانات في هذا النطاق.');
          final period = tr('Selected date range', 'نطاق التاريخ المحدد');
          final stock =
              tr('Current branch snapshot', 'لقطة المخزون الحالية للفرع');
          final fixture = tr('Sample records · independent of date filter',
              'سجلات تجريبية · لا تتأثر بفلتر التاريخ');
          final salesLabel = tr('Net sales', 'صافي المبيعات');
          final expensesLabel = tr('Operating expenses', 'مصروفات التشغيل');
          final trend = WorkspacePanel(
            title: tr('Sales and expense trend', 'اتجاه المبيعات والمصروفات'),
            caption: tr('EGP per period · tap a bar for details',
                'ج.م. لكل فترة · اضغط على عمود للتفاصيل'),
            icon: Icons.bar_chart_outlined,
            child: ReportTrend(
                buckets: snapshot.trend,
                salesLabel: salesLabel,
                expensesLabel: expensesLabel,
                empty: empty,
                money: money),
          );

          Widget bars(String title, String caption, IconData icon,
                  List<ReportValue> values, {bool monetary = false}) =>
              WorkspacePanel(
                  title: title,
                  caption: caption,
                  icon: icon,
                  child: WorkspaceRankBars(
                      values: values,
                      format: monetary ? money : count,
                      empty: empty));
          List<ReportValue> ranked(Map<String, double> values) =>
              (values.entries.map((e) => (e.key, e.value)).toList()
                    ..sort((a, b) => b.$2.compareTo(a.$2)))
                  .take(7)
                  .toList();
          Widget panels(List<Widget> children) =>
              AdaptiveColumns(minWidth: 350, maxColumns: 2, children: children);
          Widget module(ErpViewSpec spec) => WorkspacePanel(
                title: spec.title.of(context),
                caption: fixture,
                icon: spec.icon,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (branch.isAll) ...[
                      Text(
                          tr('Workspace sample totals',
                              'إجماليات مساحة العمل التجريبية'),
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      for (final metric in spec.metrics)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              Text(metric.label.of(context)),
                              Text(metric.value,
                                  style:
                                      TextStyle(color: AppColors.primaryColor)),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                        tr('Sample records by status',
                            'السجلات التجريبية حسب الحالة'),
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    WorkspaceRankBars(
                      values: AnalyticsSnapshot.statuses(spec)
                          .entries
                          .map((e) => (e.key.of(context), e.value))
                          .toList(),
                      format: count,
                      empty: empty,
                    ),
                  ],
                ),
              );
          List<Widget> modules(Set<String> ids) => AnalyticsSnapshot.modules
              .where((spec) => ids.contains(spec.id))
              .map(module)
              .toList();
          final inventoryHealth = bars(tr('Stock health', 'حالة المخزون'),
              stock, Icons.inventory_outlined, [
            (
              tr('Available', 'متوفر'),
              (snapshot.productCount - snapshot.lowStock - snapshot.outOfStock)
                  .toDouble()
            ),
            (tr('Low stock', 'مخزون منخفض'), snapshot.lowStock.toDouble()),
            (tr('Out of stock', 'نفد المخزون'), snapshot.outOfStock.toDouble()),
          ]);
          Widget composition(String title, String caption, IconData icon,
                  List<ReportValue> values, String Function(double) format) =>
              WorkspacePanel(
                title: title,
                caption: caption,
                icon: icon,
                child: WorkspaceDonut(
                    values: values, format: format, empty: empty),
              );
          final invoiceMix = composition(
            tr('Invoice mix', 'توزيع الفواتير'),
            period,
            Icons.receipt_outlined,
            [
              (
                tr('Sales invoices', 'فواتير البيع'),
                snapshot.saleCount.toDouble()
              ),
              (
                tr('Refund invoices', 'فواتير المرتجع'),
                snapshot.refundCount.toDouble()
              ),
            ],
            count,
          );
          final paymentMix = composition(
              tr('Payment mix', 'طرق الدفع'),
              tr('Gross sales by payment method',
                  'إجمالي المبيعات حسب طريقة الدفع'),
              Icons.payments_outlined,
              [
                for (final entry in ranked(snapshot.payments))
                  (
                    switch (entry.$1) {
                      'cash' => tr('Cash', 'نقدي'),
                      'card' => tr('Card', 'بطاقة'),
                      'wallet' => tr('Wallet', 'محفظة'),
                      _ => entry.$1,
                    },
                    entry.$2
                  ),
              ],
              money);
          final expenseMix = bars(
              tr('Expense categories', 'فئات المصروفات'),
              period,
              Icons.pie_chart_outline,
              [
                for (final entry in ranked(snapshot.expenseCategories))
                  (
                    switch (entry.$1) {
                      'rent' => tr('Rent', 'إيجار'),
                      'utilities' => tr('Utilities', 'مرافق'),
                      'supplies' => tr('Supplies', 'مستلزمات'),
                      'General' => tr('General', 'عام'),
                      _ => entry.$1,
                    },
                    entry.$2
                  ),
              ],
              monetary: true);

          final content = switch (_area) {
            _ReportArea.overview => [
                AdaptiveColumns(minWidth: 155, spacing: 10, children: [
                  _Metric(salesLabel, money(snapshot.net), Icons.show_chart),
                  _Metric(
                      tr('Sales invoices', 'فواتير البيع'),
                      number.format(snapshot.saleCount),
                      Icons.receipt_long_outlined),
                  _Metric(tr('Gross profit', 'مجمل الربح'),
                      money(snapshot.grossProfit), Icons.insights_outlined),
                  _Metric(expensesLabel, money(snapshot.expenseTotal),
                      Icons.payments_outlined),
                ]),
                trend,
                panels([paymentMix, invoiceMix, inventoryHealth]),
              ],
            _ReportArea.sales => [
                AdaptiveColumns(minWidth: 155, spacing: 10, children: [
                  _Metric(tr('Gross sales', 'إجمالي المبيعات'),
                      money(snapshot.gross), Icons.point_of_sale_outlined),
                  _Metric(tr('Refunds', 'المرتجعات'), money(snapshot.refunds),
                      Icons.undo),
                  _Metric(
                      tr('Refund invoices', 'فواتير المرتجع'),
                      number.format(snapshot.refundCount),
                      Icons.receipt_outlined),
                  _Metric(tr('Average sales invoice', 'متوسط فاتورة البيع'),
                      money(snapshot.averageInvoice), Icons.calculate_outlined),
                ]),
                trend,
                panels([
                  bars(
                      tr('Top products by net sales',
                          'أفضل المنتجات حسب صافي المبيعات'),
                      period,
                      Icons.leaderboard_outlined,
                      snapshot.topProducts.take(7).toList(),
                      monetary: true),
                  bars(
                      tr('Net sales by category', 'صافي المبيعات حسب الفئة'),
                      period,
                      Icons.category_outlined,
                      ranked(snapshot.salesCategories),
                      monetary: true),
                  paymentMix,
                  invoiceMix,
                  bars(tr('Sales invoices by hour', 'فواتير البيع حسب الساعة'),
                      period, Icons.schedule_outlined, [
                    for (final hour
                        in snapshot.salesByHour.keys.toList()..sort())
                      (
                        DateFormat.jm(locale.toString())
                            .format(DateTime(2000, 1, 1, hour)),
                        snapshot.salesByHour[hour]!
                      ),
                  ]),
                  ...modules({'customers'}),
                ]),
              ],
            _ReportArea.inventory => [
                AdaptiveColumns(
                    minWidth: 155,
                    spacing: 10,
                    maxColumns: 3,
                    children: [
                      _Metric(
                          tr('Products', 'المنتجات'),
                          number.format(snapshot.productCount),
                          Icons.inventory_2_outlined),
                      _Metric(tr('Units in stock', 'الوحدات في المخزون'),
                          number.format(snapshot.units), Icons.numbers),
                      _Metric(
                          tr('Stock value at cost', 'قيمة المخزون بالتكلفة'),
                          money(snapshot.inventoryValue),
                          Icons.account_balance_wallet_outlined),
                    ]),
                panels([
                  inventoryHealth,
                  bars(
                      tr('Stock value by category', 'قيمة المخزون حسب الفئة'),
                      stock,
                      Icons.category_outlined,
                      ranked(snapshot.stockCategories),
                      monetary: true),
                  ...modules({'warehouses'}),
                ]),
              ],
            _ReportArea.purchasing => [
                if (modules({'purchases', 'purchase_returns', 'suppliers'})
                    .isEmpty)
                  Text(tr('No purchasing modules are visible for this branch.',
                      'لا توجد وحدات مشتريات ظاهرة لهذا الفرع.'))
                else
                  panels(
                      modules({'purchases', 'purchase_returns', 'suppliers'})),
              ],
            _ReportArea.finance => [
                panels([
                  bars(
                      tr('Operating result breakdown', 'تفاصيل نتيجة التشغيل'),
                      tr('Net sales less cost of sales and operating expenses',
                          'صافي المبيعات مطروحاً منه تكلفة المبيعات ومصروفات التشغيل'),
                      Icons.account_balance_outlined,
                      [
                        (salesLabel, snapshot.net),
                        (tr('Cost of sales', 'تكلفة المبيعات'), snapshot.cost),
                        (expensesLabel, snapshot.expenseTotal),
                        (
                          tr('Operating result', 'نتيجة التشغيل'),
                          snapshot.operatingResult
                        ),
                      ],
                      monetary: true),
                  expenseMix,
                  ...modules({'finance'}),
                ]),
              ],
            _ReportArea.operations => [
                panels([
                  bars(
                      tr('User roles', 'أدوار المستخدمين'),
                      tr('Workspace snapshot · all users',
                          'لقطة مساحة العمل · جميع المستخدمين'),
                      Icons.manage_accounts_outlined,
                      [
                        (
                          tr('Managers', 'المديرون'),
                          snapshot.managers.toDouble()
                        ),
                        (
                          tr('Cashiers', 'أمناء الصندوق'),
                          snapshot.cashiers.toDouble()
                        ),
                      ]),
                  bars(tr('Stock alert sources', 'مصادر تنبيهات المخزون'),
                      stock, Icons.notifications_none, [
                    (
                      tr('Low stock', 'مخزون منخفض'),
                      snapshot.lowStock.toDouble()
                    ),
                    (
                      tr('Out of stock', 'نفد المخزون'),
                      snapshot.outOfStock.toDouble()
                    ),
                  ]),
                  ...modules({'customers', 'warehouses'}),
                ]),
              ],
          };

          return LayoutBuilder(
              builder: (context, limits) => ListView(
                    padding: LayoutTokens.pagePadding(limits.maxWidth),
                    children: [
                      Center(
                          child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1500),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              WorkspacePanel(
                                prominent: true,
                                title: tr(
                                    'Analytics workspace', 'مساحة التحليلات'),
                                caption: tr(
                                    'Sales, inventory and operations in one place · Sample data',
                                    'المبيعات والمخزون والتشغيل في مكان واحد · بيانات تجريبية'),
                                icon: Icons.analytics_outlined,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                          spacing: 12,
                                          runSpacing: 6,
                                          children: [
                                            Text(branch.label(ar),
                                                style: TextStyle(
                                                    color: AppColors
                                                        .primaryColor)),
                                            Text(
                                                '${date.format(range.start)} – ${date.format(range.end)}',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.mutedColor)),
                                          ]),
                                      const SizedBox(height: 10),
                                      Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: [
                                            for (final days in [7, 30, 90, 365])
                                              ChoiceChip(
                                                  label: Text(tr(
                                                      'Last $days days',
                                                      'آخر $days يوم')),
                                                  selected: _custom == null &&
                                                      _days == days,
                                                  onSelected: (_) =>
                                                      setState(() {
                                                        _days = days;
                                                        _custom = null;
                                                      })),
                                            ChoiceChip(
                                                avatar: const Icon(
                                                    Icons.date_range_outlined,
                                                    size: 16),
                                                label: Text(tr('Custom range',
                                                    'نطاق مخصص')),
                                                selected: _custom != null,
                                                onSelected: (_) =>
                                                    _pickDates()),
                                          ]),
                                      const SizedBox(height: 12),
                                      Text(
                                          tr('Dates apply to sales and expenses. Snapshot cards show the current records.',
                                              'تنطبق التواريخ على المبيعات والمصروفات. تعرض اللقطات السجلات الحالية.'),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.mutedColor)),
                                    ]),
                              ),
                              const SizedBox(height: 14),
                              Wrap(spacing: 8, runSpacing: 6, children: [
                                for (final area in _ReportArea.values)
                                  ChoiceChip(
                                      avatar: Icon(area.icon, size: 16),
                                      label: Text(tr(area.en, area.ar)),
                                      selected: _area == area,
                                      onSelected: (_) =>
                                          setState(() => _area = area)),
                              ]),
                              const SizedBox(height: 14),
                              for (final panel in content) ...[
                                panel,
                                const SizedBox(height: 16)
                              ],
                            ]),
                      )),
                    ],
                  ));
        },
      );
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 20, color: AppColors.secondaryColor),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColors.mutedColor)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
        ]),
      );
}
