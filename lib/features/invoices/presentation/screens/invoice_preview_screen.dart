import 'package:flutter/material.dart';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/shared/feedback/preview_action.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import '../models/invoice_document_view_data.dart';
import '../widgets/invoice_document_preview.dart';

class InvoicePreviewScreen extends StatefulWidget {
  const InvoicePreviewScreen(
      {super.key, required this.data, this.receiptMode = true});
  final InvoiceData data;
  final bool receiptMode;
  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  late bool _receiptMode = widget.receiptMode;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final arabic = locale.languageCode == 'ar';
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        toolbarHeight: 72,
        titleSpacing: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_receiptMode ? l10n.thermalReceiptLabel : l10n.a4InvoiceLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(l10n.invoiceNumberLabel(widget.data.invoiceId),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.mutedColor)),
        ]),
        actions: [
          IconButton(
              tooltip: l10n.quickPrintTooltip,
              onPressed: () => showPreviewAction(context),
              icon: Icon(Icons.print_outlined,
                  color: AppColors.primaryColor, size: 21)),
          IconButton(
              tooltip: l10n.sharePdfTooltip,
              onPressed: () => showPreviewAction(context),
              icon: Icon(Icons.ios_share_outlined,
                  color: AppColors.secondaryColor, size: 20)),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
          child: Column(children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                border:
                    Border(bottom: BorderSide(color: AppColors.borderColor))),
            child: Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(arabic ? 'تنسيق المستند' : 'Document format',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  ChoiceChip(
                      label: Text(arabic ? 'إيصال 80 مم' : '80 mm receipt'),
                      selected: _receiptMode,
                      showCheckmark: false,
                      selectedColor: AppColors.primaryColor,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _receiptMode
                              ? AppColors.primaryForeground
                              : AppColors.textPrimary),
                      onSelected: (_) => setState(() => _receiptMode = true)),
                  ChoiceChip(
                      label: const Text('A4'),
                      selected: !_receiptMode,
                      showCheckmark: false,
                      selectedColor: AppColors.primaryColor,
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: !_receiptMode
                              ? AppColors.primaryForeground
                              : AppColors.textPrimary),
                      onSelected: (_) => setState(() => _receiptMode = false)),
                  if (widget.data.branchId case final branch?)
                    WorkspacePill(
                      label: BranchPreviewController.labelFor(branch, arabic),
                      color: AppColors.primaryColor,
                      icon: Icons.storefront_outlined,
                    ),
                  Text(
                      arabic
                          ? 'معاينة فقط • الطباعة والمشاركة غير مفعّلتين'
                          : 'Preview only • printing and sharing are inactive',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppColors.mutedColor)),
                ])),
        Expanded(
            child: InvoiceDocumentPreview(
          data: widget.data,
          receiptMode: _receiptMode,
        )),
      ])),
    );
  }
}
