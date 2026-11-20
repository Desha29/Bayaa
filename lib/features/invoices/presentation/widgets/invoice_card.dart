import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/workspace/workspace_summary.dart';
import 'package:bayaa_pos/shared/localization/translation_helper.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/features/pos/presentation/models/invoice_view_data.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    super.key,
    required this.sale,
    required this.onOpen,
    required this.onPrint,
    this.onDelete,
    this.onReturn,
    required this.isManager,
  });

  final InvoiceViewData sale;
  final VoidCallback onOpen, onPrint;
  final VoidCallback? onDelete, onReturn;
  final bool isManager;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ar = l.localeName == 'ar';
    final tone = sale.isRefund ? AppColors.errorColor : AppColors.primaryColor;

    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 220;
      return Material(
        color: AppColors.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: tone.withValues(alpha: .2),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top colored accent
                Container(
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: tone,
                    gradient: LinearGradient(
                      colors: [tone, tone.withValues(alpha: 0.65)],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 10 : 14,
                      compact ? 9 : 12,
                      compact ? 10 : 14,
                      compact ? 6 : 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header: Invoice # and Payment method
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${sale.id.replaceFirst('DEMO-', '')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: compact ? 12 : 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            WorkspacePill(
                              label: sale.paymentMethod == 'cash'
                                  ? (ar ? 'نقدي' : 'Cash')
                                  : (ar ? 'بطاقة' : 'Card'),
                              color: AppColors.secondaryColor,
                              icon: Icons.payments_outlined,
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 5 : 7),

                        // Status pill & items count
                        Row(
                          children: [
                            WorkspacePill(
                              label: sale.isRefund
                                  ? l.refundsFilter
                                  : (ar ? 'مدفوعة' : 'Paid'),
                              color: tone,
                              icon: sale.isRefund
                                  ? Icons.undo_rounded
                                  : Icons.check_circle_outline,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.mutedColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2_outlined,
                                      size: compact ? 11 : 13,
                                      color: AppColors.mutedColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${sale.items} ${ar ? 'أصناف' : 'items'}',
                                    style: TextStyle(
                                      fontSize: compact ? 9.5 : 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.mutedColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 5 : 7),

                        // Total amount
                        Text(
                          '${sale.isRefund ? '-' : ''}${sale.total.abs().toStringAsFixed(2)} ${l.currencyEg}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 17 : 22,
                            fontWeight: FontWeight.w900,
                            color: tone,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: compact ? 5 : 7),

                        // Cashier
                        _detail(
                          Icons.person_outline,
                          TranslationHelper.translateUserName(
                              context, sale.cashierName ?? l.cashier),
                          compact: compact,
                        ),
                        SizedBox(height: compact ? 3 : 4),

                        // Date and Time beside each other
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: compact ? 11 : 13,
                                color: AppColors.mutedColor),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('d MMM', l.localeName)
                                  .format(sale.date),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: compact ? 10 : 11,
                                color: AppColors.mutedColor,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text('·',
                                  style: TextStyle(
                                    color: AppColors.mutedColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: compact ? 10 : 12,
                                  )),
                            ),
                            Icon(Icons.access_time_rounded,
                                size: compact ? 11 : 13,
                                color: AppColors.mutedColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                DateFormat('hh:mm a', l.localeName)
                                    .format(sale.date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: compact ? 9.5 : 11,
                                  color: AppColors.mutedColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.borderColor.withValues(alpha: 0.6)),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: compact ? 4 : 6, vertical: compact ? 4 : 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        icon: Icons.visibility_outlined,
                        color: AppColors.primaryColor,
                        tooltip: ar ? 'عرض الفاتورة' : 'View invoice',
                        onPressed: onOpen,
                        compact: compact,
                      ),
                      _actionButton(
                        icon: Icons.print_outlined,
                        color: AppColors.secondaryColor,
                        tooltip: ar ? 'طباعة' : 'Print',
                        onPressed: onPrint,
                        compact: compact,
                      ),
                      if (onReturn != null)
                        _actionButton(
                          icon: Icons.undo_rounded,
                          color: AppColors.warningColor,
                          tooltip: ar ? 'مرتجع' : 'Refund',
                          onPressed: onReturn,
                          compact: compact,
                        ),
                      if (isManager)
                        _actionButton(
                          icon: Icons.delete_outline,
                          color: AppColors.errorColor,
                          tooltip: l.delete,
                          onPressed: onDelete,
                          compact: compact,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onPressed,
    required bool compact,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 9 : 12, vertical: compact ? 6 : 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.22), width: 0.8),
          ),
          child: Icon(icon, size: compact ? 20 : 22, color: color),
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text, {bool compact = false}) => Row(
        children: [
          Icon(icon, size: compact ? 12.5 : 14, color: AppColors.mutedColor),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: compact ? 10.5 : 11.5,
                color: AppColors.mutedColor,
              ),
            ),
          ),
        ],
      );
}
