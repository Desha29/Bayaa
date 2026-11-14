import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';
import 'package:bayaa_pos/shared/widgets/erp/erp_view_spec.dart';
import 'package:bayaa_pos/features/customers/presentation/views/customers_view.dart';

typedef CheckoutPreview = ({String branchId, String paymentMethod});

/// Returns only the choices needed to display the unsaved invoice.
Future<CheckoutPreview?> showPosCheckoutDialog(BuildContext context,
        {required double total, required int itemCount}) =>
    showDialog<CheckoutPreview>(
        context: context,
        builder: (_) => PosCheckoutDialog(total: total, itemCount: itemCount));

class PosCheckoutDialog extends StatefulWidget {
  const PosCheckoutDialog(
      {super.key, required this.total, required this.itemCount});
  final double total;
  final int itemCount;
  @override
  State<PosCheckoutDialog> createState() => _PosCheckoutDialogState();
}

class _PosCheckoutDialogState extends State<PosCheckoutDialog> {
  final _form = GlobalKey<FormState>();
  final _paidFocus = FocusNode();
  late final _paid =
      TextEditingController(text: widget.total.toStringAsFixed(2));
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  final _reference = TextEditingController();
  late String? _branchId = BranchPreviewController.instance.isAll
      ? null
      : BranchPreviewController.instance.activeId;
  String _method = 'cash';
  String _saleType = 'retail';
  String _account = 'main';
  bool _partial = false;
  bool _newCustomer = false;
  ErpRecordView? _customer;

  bool get _ar => Localizations.localeOf(context).languageCode == 'ar';
  String _copy(String ar, String en) => _ar ? ar : en;
  String get _currency => _copy('ج.م', 'EGP');
  String _money(double value) => '${value.toStringAsFixed(2)} $_currency';
  double get _paidValue {
    final amount = double.tryParse(_paid.text.trim());
    return amount != null && amount.isFinite ? amount : 0;
  }

  @override
  void dispose() {
    _paidFocus.dispose();
    _paid.dispose();
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: AppColors.surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 900),
        child: LayoutBuilder(builder: (context, size) {
          final short = size.maxHeight < 360;
          final body = Form(
              key: _form,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child:
                  Padding(padding: const EdgeInsets.all(20), child: _body()));
          final column = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                Divider(height: 1, color: AppColors.borderColor),
                if (short)
                  body
                else
                  Flexible(child: SingleChildScrollView(child: body)),
                _footer(),
              ]);
          return short ? SingleChildScrollView(child: column) : column;
        }),
      ),
    );
  }

  Widget _header() => Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.payments_outlined,
                color: AppColors.primaryColor, size: 22)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_copy('إتمام الفاتورة', 'Checkout'),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(
              _copy('معاينة الدفع • ${widget.itemCount} أصناف',
                  'Payment preview • ${widget.itemCount} items'),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.mutedColor)),
        ])),
        IconButton(
            tooltip: _copy('إغلاق', 'Close'),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 21)),
      ]));

  Widget _body() =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor)),
            child: Column(children: [
              _summary(
                  _copy('المجموع الفرعي', 'Subtotal'), _money(widget.total)),
              const SizedBox(height: 10),
              _summary(
                  _copy('عدد الأصناف', 'Line items'), '${widget.itemCount}'),
              Divider(height: 24, color: AppColors.borderColor),
              _summary(
                  _copy('الإجمالي المستحق', 'Total due'), _money(widget.total),
                  emphasized: true),
            ])),
        const SizedBox(height: 22),
        DropdownButtonFormField<String>(
          initialValue: _branchId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: _copy('فرع الفاتورة', 'Invoice branch'),
            hintText: _copy('اختر الفرع', 'Select a branch'),
            prefixIcon: const Icon(Icons.storefront_outlined),
          ),
          items: [
            for (final id in BranchPreviewController.branchIds.skip(1))
              DropdownMenuItem(
                value: id,
                child: Text(BranchPreviewController.labelFor(id, _ar),
                    overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (id) => setState(() => _branchId = id),
        ),
        const SizedBox(height: 22),
        _heading(_copy('طريقة الدفع', 'Payment method'),
            Icons.account_balance_wallet_outlined),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, size) {
          final columns = MediaQuery.textScalerOf(context).scale(1) > 1.3
              ? 1
              : (size.maxWidth >= 540 ? 3 : 2);
          final width = (size.maxWidth - (columns - 1) * 10) / columns;
          return Wrap(spacing: 10, runSpacing: 10, children: [
            for (final method in [
              ('cash', _copy('نقدي', 'Cash'), Icons.payments_outlined),
              (
                'card',
                _copy('بطاقة / POS', 'Card / POS'),
                Icons.credit_card_outlined
              ),
              (
                'bank',
                _copy('تحويل بنكي', 'Bank transfer'),
                Icons.account_balance_outlined
              ),
              (
                'vodafone',
                _copy('فودافون كاش', 'Vodafone Cash'),
                Icons.phone_android_outlined
              ),
              (
                'orange',
                _copy('أورنج كاش', 'Orange Cash'),
                Icons.smartphone_outlined
              ),
              (
                'etisalat',
                _copy('اتصالات كاش', 'Etisalat Cash'),
                Icons.account_balance_wallet_outlined
              ),
            ])
              SizedBox(
                  width: width,
                  child: OutlinedButton(
                      onPressed: () => setState(() {
                            _method = method.$1;
                            _account = method.$1 == 'cash'
                                ? 'main'
                                : (method.$1 == 'bank' || method.$1 == 'card'
                                    ? 'bank'
                                    : 'wallet');
                          }),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 14),
                          backgroundColor: _method == method.$1
                              ? AppColors.primaryColor.withValues(alpha: .07)
                              : AppColors.surfaceColor,
                          foregroundColor: _method == method.$1
                              ? AppColors.primaryColor
                              : AppColors.textSecondary,
                          side: BorderSide(
                              color: _method == method.$1
                                  ? AppColors.primaryColor
                                  : AppColors.borderColor,
                              width: _method == method.$1 ? 1.5 : 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(method.$3, size: 22),
                        const SizedBox(height: 7),
                        Text(method.$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 5),
                        SizedBox(
                            height: 13,
                            child: _method == method.$1
                                ? const Icon(Icons.check_circle_rounded,
                                    size: 13)
                                : null),
                      ]))),
          ]);
        }),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
            key: ValueKey(_account),
            initialValue: _account,
            isExpanded: true,
            decoration: InputDecoration(
                labelText: _copy('حساب التحصيل', 'Receiving account'),
                prefixIcon:
                    const Icon(Icons.account_balance_outlined, size: 20)),
            items: [
              DropdownMenuItem(
                  value: 'main',
                  child: Text(_copy(
                      'الخزينة الرئيسية (مثال)', 'Main cashbox (example)'))),
              DropdownMenuItem(
                  value: 'bank',
                  child: Text(
                      _copy('الحساب البنكي (مثال)', 'Bank account (example)'))),
              DropdownMenuItem(
                  value: 'wallet',
                  child: Text(
                      _copy('محفظة المتجر (مثال)', 'Store wallet (example)'))),
            ],
            onChanged: (value) => setState(() => _account = value ?? 'main')),
        if (_method != 'cash') ...[
          const SizedBox(height: 14),
          TextField(
              controller: _reference,
              decoration: InputDecoration(
                  labelText: _copy(
                      'مرجع العملية (اختياري)', 'Payment reference (optional)'),
                  prefixIcon: const Icon(Icons.tag_rounded, size: 20))),
        ],
        const SizedBox(height: 22),
        _heading(
            _copy('حالة السداد', 'Payment status'), Icons.fact_check_outlined),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 8, children: [
          _choice(
              _copy('سداد كامل', 'Full payment'),
              !_partial,
              () => setState(() {
                    _partial = false;
                    _paid.text = widget.total.toStringAsFixed(2);
                  })),
          _choice(
              _copy('جزئي / آجل', 'Partial / credit'),
              _partial,
              () => setState(() {
                    _partial = true;
                    _paid.text = '0.00';
                  })),
        ]),
        const SizedBox(height: 14),
        TextFormField(
            controller: _paid,
            focusNode: _paidFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: _partial
                    ? _copy('المدفوع الآن', 'Paid now')
                    : _copy('المبلغ المستلم', 'Amount received'),
                suffixText: _currency,
                prefixIcon: const Icon(Icons.payments_outlined, size: 20)),
            validator: (text) {
              final amount = double.tryParse(text?.trim() ?? '');
              if (amount == null || !amount.isFinite || amount < 0) {
                return _copy('أدخل مبلغاً صالحاً', 'Enter a valid amount');
              }
              if (_partial && amount > widget.total) {
                return _copy('المدفوع لا يتجاوز الإجمالي',
                    'Paid amount cannot exceed the total');
              }
              if (!_partial && amount < widget.total) {
                return _copy('اختر السداد الجزئي للمبلغ الأقل',
                    'Choose partial payment for a lower amount');
              }
              return null;
            }),
        const SizedBox(height: 10),
        _summary(
            _partial
                ? _copy('المتبقي (معاينة)', 'Remaining (preview)')
                : _copy('الباقي للعميل (معاينة)', 'Change (preview)'),
            _money((_partial
                    ? widget.total - _paidValue
                    : _paidValue - widget.total)
                .clamp(0, double.infinity)
                .toDouble()),
            emphasized: false),
        const SizedBox(height: 22),
        _heading(_copy('نوع البيع', 'Sale type'), Icons.storefront_outlined),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 8, children: [
          _choice(_copy('تجزئة', 'Retail'), _saleType == 'retail',
              () => setState(() => _saleType = 'retail')),
          _choice(_copy('جملة', 'Wholesale'), _saleType == 'wholesale',
              () => setState(() => _saleType = 'wholesale')),
        ]),
        const SizedBox(height: 6),
        Text(
            _copy('اختيار للمعاينة فقط؛ لا يغير أسعار الفاتورة.',
                'Preview selection only; order prices stay unchanged.'),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppColors.mutedColor)),
        const SizedBox(height: 22),
        _heading(_copy('بيانات العميل', 'Customer details'),
            Icons.person_outline_rounded),
        const SizedBox(height: 12),
        Autocomplete<ErpRecordView>(
          displayStringForOption: (option) => option.title,
          optionsMaxHeight: 190,
          optionsBuilder: (query) {
            final text = query.text.toLowerCase();
            return customersView.records.where((record) =>
                '${record.title} ${record.cells[1]}'
                    .toLowerCase()
                    .contains(text));
          },
          onSelected: (record) => setState(() {
            _customer = record;
            _newCustomer = false;
            _name.text = record.title;
            _phone.text = record.cells[1];
          }),
          fieldViewBuilder: (context, controller, focus, submit) => TextField(
              controller: controller,
              focusNode: focus,
              onSubmitted: (_) => submit(),
              onChanged: (_) => setState(() => _customer = null),
              decoration: InputDecoration(
                  labelText: _copy('البحث عن عميل بالاسم أو الهاتف',
                      'Find customer by name or phone'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: _copy('مسح البحث', 'Clear search'),
                          onPressed: () {
                            controller.clear();
                            focus.requestFocus();
                            setState(() => _customer = null);
                          },
                          icon: const Icon(Icons.close, size: 18)))),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
              child: Text(
                  _customer == null
                      ? _copy('عميل نقدي / بدون حساب',
                          'Walk-in customer / no account')
                      : _customer!.id,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.mutedColor))),
          Flexible(
              child: TextButton.icon(
                  onPressed: () => setState(() => _newCustomer = !_newCustomer),
                  icon: Icon(
                      _newCustomer
                          ? Icons.remove
                          : Icons.person_add_alt_1_outlined,
                      size: 17),
                  label: Text(_copy('عميل جديد', 'New customer'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 11)))),
        ]),
        if (_newCustomer)
          Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                  _copy('بيانات للمعاينة؛ لن يُنشأ حساب عميل.',
                      'Preview details; no customer account will be created.'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.mutedColor))),
        AdaptiveColumns(minWidth: 260, maxColumns: 2, spacing: 14, children: [
          TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText:
                      _copy('اسم العميل (اختياري)', 'Customer name (optional)'),
                  prefixIcon: const Icon(Icons.person_outline, size: 20))),
          TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText:
                      _copy('رقم الهاتف (اختياري)', 'Phone number (optional)'),
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20))),
        ]),
        const SizedBox(height: 14),
        TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
                labelText: _copy(
                    'ملاحظات الفاتورة (اختياري)', 'Order notes (optional)'),
                alignLabelWithHint: true)),
      ]);

  Widget _heading(String label, IconData icon) => Row(children: [
        Icon(icon, size: 19, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary))),
      ]);

  Widget _choice(String label, bool selected, VoidCallback onTap) => ChoiceChip(
      selected: selected,
      label: Text(label),
      showCheckmark: false,
      selectedColor: AppColors.primaryColor,
      labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color:
              selected ? AppColors.primaryForeground : AppColors.textSecondary),
      side: BorderSide(
          color: selected ? AppColors.primaryColor : AppColors.borderColor),
      onSelected: (_) => onTap());

  Widget _summary(String label, String value, {bool emphasized = false}) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: emphasized ? 13 : 12,
                    fontWeight: emphasized ? FontWeight.w800 : FontWeight.bold,
                    color: AppColors.textSecondary))),
        const SizedBox(width: 12),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: emphasized ? 22 : 13,
                    fontWeight: FontWeight.w800,
                    color: emphasized
                        ? AppColors.primaryColor
                        : AppColors.textPrimary))),
      ]);

  Widget _footer() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          border: Border(top: BorderSide(color: AppColors.borderColor))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
            _branchId == null
                ? _copy('اختر فرع الفاتورة للمتابعة.',
                    'Choose an invoice branch to continue.')
                : _copy('معاينة فقط — لا يتم تحصيل أموال أو حفظ الفاتورة.',
                    'Preview only — no funds are collected or invoices saved.'),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppColors.mutedColor)),
        const SizedBox(height: 12),
        Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_copy('إلغاء', 'Cancel'))),
              FilledButton.icon(
                  onPressed: _branchId == null
                      ? null
                      : () {
                          if (_form.currentState!.validate()) {
                            Navigator.pop<CheckoutPreview>(context,
                                (branchId: _branchId!, paymentMethod: _method));
                          } else {
                            _paidFocus.requestFocus();
                          }
                        },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(_copy('معاينة الفاتورة', 'Preview invoice')),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: AppColors.accentForeground,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14))),
            ]),
      ]));
}
