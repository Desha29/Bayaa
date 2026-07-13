import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/translation_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../sales/data/models/sale_model.dart';

class InvoiceCard extends StatefulWidget {
  final Sale sale;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;
  final VoidCallback? onReturn;
  final VoidCallback onPrint;
  final bool isManager;

  const InvoiceCard({
    Key? key,
    required this.sale,
    required this.onOpen,
    this.onReturn,
    required this.onPrint,
    this.onDelete,
    required this.isManager,
  }) : super(key: key);

  @override
  State<InvoiceCard> createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<InvoiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final df = DateFormat('yyyy-MM-dd  hh:mm a', 'en');
    final cashierName = TranslationHelper.translateUserName(
      context,
      widget.sale.cashierName ?? l10n.cashier,
    );
    final sale = widget.sale;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;
    final statusColor =
        sale.isRefund ? AppColors.errorColor : AppColors.primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? AppColors.primaryColor.withOpacity(0.3)
                : AppColors.borderColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primaryColor.withOpacity(0.06)
                  : Colors.black.withOpacity(0.02),
              blurRadius: _isHovered ? 12 : 6,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Right-side indicator strip (first element in RTL)
                Container(
                  width: 4,
                  color: statusColor,
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onOpen,
                      borderRadius: l10n.localeName == 'ar'
                          ? const BorderRadius.only(
                              topRight: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            )
                          : const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              bottomLeft: Radius.circular(14),
                            ),
                      child: Padding(
                        padding: EdgeInsets.all(isCompact ? 12 : 16),
                        child: isCompact
                            ? _buildCompactLayout(sale, df, cashierName)
                            : _buildDesktopLayout(sale, df, cashierName),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Sale sale, DateFormat df, String cashierName) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        // Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                (sale.isRefund ? AppColors.errorColor : AppColors.primaryColor)
                    .withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            sale.isRefund ? LucideIcons.undo2 : LucideIcons.fileSpreadsheet,
            color:
                sale.isRefund ? AppColors.errorColor : AppColors.primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.invoiceNumber(
                        sale.id.length > 8 ? sale.id.substring(0, 8) : sale.id),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (sale.isRefund) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.errorColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.errorColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        l10n.refunded,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildInfoChip(LucideIcons.user, cashierName),
                  _buildDot(),
                  _buildInfoChip(
                      LucideIcons.package, l10n.itemsCount(sale.items)),
                  _buildDot(),
                  _buildInfoChip(LucideIcons.clock, df.format(sale.date)),
                ],
              ),
            ],
          ),
        ),
        // Total + Actions
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${sale.total.toStringAsFixed(2)} ${l10n.currencyEg}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: sale.isRefund
                    ? AppColors.errorColor
                    : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildActions(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout(Sale sale, DateFormat df, String cashierName) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (sale.isRefund
                        ? AppColors.errorColor
                        : AppColors.primaryColor)
                    .withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                sale.isRefund ? LucideIcons.undo2 : LucideIcons.fileSpreadsheet,
                color: sale.isRefund
                    ? AppColors.errorColor
                    : AppColors.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.invoiceNumber(sale.id.length > 8
                            ? sale.id.substring(0, 8)
                            : sale.id),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (sale.isRefund) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.refunded,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    df.format(sale.date),
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: AppColors.mutedColor),
                  ),
                ],
              ),
            ),
            Text(
              '${sale.total.toStringAsFixed(2)} ${l10n.currencyEg}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: sale.isRefund
                    ? AppColors.errorColor
                    : AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildInfoChip(LucideIcons.user, cashierName),
            _buildDot(),
            _buildInfoChip(LucideIcons.package, l10n.itemsCount(sale.items)),
            const Spacer(),
            ...List.generate(_buildActions().length, (i) {
              final actions = _buildActions();
              if (i > 0)
                return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: actions[i]);
              return actions[i];
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.mutedColor.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('·',
          style: TextStyle(
              color: AppColors.mutedColor.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 14)),
    );
  }

  List<Widget> _buildActions() {
    final l10n = AppLocalizations.of(context);
    return [
      if (widget.onReturn != null)
        _buildActionButton(
          LucideIcons.undo2,
          l10n.refundBtn,
          AppColors.warningColor,
          widget.onReturn!,
        ),
      if (widget.isManager && widget.onDelete != null) ...[
        const SizedBox(width: 6),
        _buildActionButton(
          LucideIcons.trash2,
          l10n.delete,
          AppColors.errorColor,
          widget.onDelete!,
        ),
      ],
      const SizedBox(width: 6),
      _buildActionButton(
        LucideIcons.printer,
        l10n.print,
        AppColors.primaryColor,
        widget.onPrint,
      ),
    ];
  }

  Widget _buildActionButton(
      IconData icon, String tooltip, Color color, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.12)),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
        ),
      ),
    );
  }
}
