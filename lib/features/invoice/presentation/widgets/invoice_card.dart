import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
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
    final df = DateFormat('yyyy-MM-dd  hh:mm a');
    final cashierName = widget.sale.cashierName ?? 'الكاشير';
    final sale = widget.sale;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 700;

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
                ? AppColors.primaryColor.withOpacity(0.25)
                : AppColors.borderColor.withOpacity(0.4),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primaryColor.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onOpen,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 16),
              child: isCompact ? _buildCompactLayout(sale, df, cashierName) : _buildDesktopLayout(sale, df, cashierName),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(Sale sale, DateFormat df, String cashierName) {
    return Row(
      children: [
        // Icon
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: sale.isRefund
                  ? [AppColors.errorColor.withOpacity(0.12), AppColors.errorColor.withOpacity(0.05)]
                  : [AppColors.primaryColor.withOpacity(0.12), AppColors.primaryColor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            sale.isRefund ? Icons.undo_rounded : Icons.receipt_long_rounded,
            color: sale.isRefund ? AppColors.errorColor : AppColors.primaryColor,
            size: 24,
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
                    'فاتورة #${sale.id.length > 8 ? sale.id.substring(0, 8) : sale.id}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (sale.isRefund) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.errorColor.withOpacity(0.12), AppColors.errorColor.withOpacity(0.06)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.errorColor.withOpacity(0.2)),
                      ),
                      child: const Text(
                        'مرتجع',
                        style: TextStyle(
                          fontSize: 11,
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
                  _buildInfoChip(Icons.person_outline_rounded, cashierName),
                  _buildDot(),
                  _buildInfoChip(Icons.inventory_2_outlined, '${sale.items} صنف'),
                  _buildDot(),
                  _buildInfoChip(Icons.access_time_rounded, df.format(sale.date)),
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
              '${sale.total.toStringAsFixed(2)} ج.م',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: sale.isRefund ? AppColors.errorColor : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: sale.isRefund
                      ? [AppColors.errorColor.withOpacity(0.12), AppColors.errorColor.withOpacity(0.05)]
                      : [AppColors.primaryColor.withOpacity(0.12), AppColors.primaryColor.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                sale.isRefund ? Icons.undo_rounded : Icons.receipt_long_rounded,
                color: sale.isRefund ? AppColors.errorColor : AppColors.primaryColor,
                size: 20,
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
                        'فاتورة #${sale.id.length > 8 ? sale.id.substring(0, 8) : sale.id}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      if (sale.isRefund) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('مرتجع', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.errorColor)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(df.format(sale.date), style: TextStyle(fontSize: 11, color: AppColors.mutedColor)),
                ],
              ),
            ),
            Text(
              '${sale.total.toStringAsFixed(2)} ج.م',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sale.isRefund ? AppColors.errorColor : AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildInfoChip(Icons.person_outline_rounded, cashierName),
            _buildDot(),
            _buildInfoChip(Icons.inventory_2_outlined, '${sale.items} صنف'),
            const Spacer(),
            ...List.generate(_buildActions().length, (i) {
              final actions = _buildActions();
              if (i > 0) return Padding(padding: const EdgeInsets.only(right: 4), child: actions[i]);
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
        Icon(icon, size: 13, color: AppColors.mutedColor.withOpacity(0.7)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('·', style: TextStyle(color: AppColors.mutedColor, fontWeight: FontWeight.bold)),
    );
  }

  List<Widget> _buildActions() {
    return [
      if (widget.onReturn != null)
        _buildActionButton(
          Icons.undo_rounded,
          'مرتجع',
          AppColors.warningColor,
          widget.onReturn!,
        ),
      if (widget.isManager && widget.onDelete != null) ...[
        const SizedBox(width: 6),
        _buildActionButton(
          Icons.delete_outline_rounded,
          'حذف',
          AppColors.errorColor,
          widget.onDelete!,
        ),
      ],
      const SizedBox(width: 6),
      _buildActionButton(
        Icons.print_rounded,
        'طباعة',
        AppColors.primaryColor,
        widget.onPrint,
      ),
    ];
  }

  Widget _buildActionButton(IconData icon, String tooltip, Color color, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.12)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}
