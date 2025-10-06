import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';

class EnhancedProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final Color statusColor;
  final String statusText;

  const EnhancedProductCard({
    super.key,
    required this.product,
    required this.onDelete,
    required this.onEdit,
    required this.statusColor,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final qty = product['qty'] as int;
    final min = product['min'] as int;
    final isLowStock = qty > 0 && qty <= min;
    final isOutOfStock = qty == 0;

    final pad = ResponsiveHelper.padding(context);
    final titleSize = ResponsiveHelper.fontSize(
      context,
      mobile: 13,
      tablet: 15,
      desktop: 17,
    );
    final small = ResponsiveHelper.fontSize(
      context,
      mobile: 10,
      tablet: 11,
      desktop: 12,
    );
    final value = ResponsiveHelper.fontSize(
      context,
      mobile: 12,
      tablet: 13,
      desktop: 14,
    );

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red.withOpacity(0.25)
              : isLowStock
              ? Colors.orange.withOpacity(0.25)
              : Colors.grey.withOpacity(0.15),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          pad.left.clamp(6.0, 12.0),
          pad.top.clamp(6.0, 12.0),
          pad.right.clamp(6.0, 12.0),
          pad.bottom.clamp(6.0, 12.0),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tightW = constraints.maxWidth < 180;
            final tightH = constraints.maxHeight < 240;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top image
                Flexible(
                  flex: 2,
                  child: _CategoryImage(tightH: tightH, tightW: tightW),
                ),

                SizedBox(height: tightH ? 4 : 6),

                // Header row
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            product['name'] ?? '---',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: titleSize,
                              color: const Color(0xff1e293b),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: tightW ? 4 : 6),
                      _StatusChip(
                        text: statusText,
                        color: statusColor,
                        font: small,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: tightH ? 2 : 4),

                Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      product['code']?.toString() ?? '---',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: small,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: tightH ? 4 : 6),

                Flexible(
                  flex: 2,
                  child: _InfoGrid(
                    small: small,
                    value: value,
                    qty: qty,
                    product: product,
                    tightW: tightW,
                  ),
                ),
                SizedBox(height: tightH ? 12 : 18),
                Expanded(
                  child: _ActionsBar(
                    edit: onEdit,
                    del: onDelete,
                    value: value,
                    tightH: tightH,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final bool tightH;
  final bool tightW;
  const _CategoryImage({required this.tightH, required this.tightW});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: EdgeInsets.all(tightW ? 4 : 6),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset(
              'assets/images/p_image.png',
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.image_outlined, size: 36, color: Colors.grey[400]),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final double font;
  const _StatusChip({
    required this.text,
    required this.color,
    required this.font,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: FittedBox(
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: font,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final double small;
  final double value;
  final int qty;
  final Map<String, dynamic> product;
  final bool tightW;
  const _InfoGrid({
    required this.small,
    required this.value,
    required this.qty,
    required this.product,
    required this.tightW,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String val, IconData icon, Color color) {
      // Remove Flexible; Wrap children must not be Flexible
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: tightW ? 60 : 68, maxWidth: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(icon, color: color, size: value + 2),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(fontSize: small, color: Colors.grey[700]),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    val,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: value,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      spacing: 10,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: FittedBox(
            child: chip(
              'السعر',
              '${product['price']}',
              Icons.attach_money_rounded,
              const Color(0xff059669),
            ),
          ),
        ),
        Flexible(
          child: FittedBox(
            child: chip(
              'المتوفر',
              qty.toString(),
              Icons.inventory_2_rounded,
              qty == 0 ? Colors.red : const Color(0xff0fa2a9),
            ),
          ),
        ),
        Flexible(
          child: FittedBox(
            child: chip(
              'التصنيف',
              (product['category'] ?? '---').toString(),
              Icons.category_rounded,
              const Color(0xff8b5cf6),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionsBar extends StatelessWidget {
  final VoidCallback edit;
  final VoidCallback del;
  final double value;
  final bool tightH;
  const _ActionsBar({
    required this.edit,
    required this.del,
    required this.value,
    required this.tightH,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: FittedBox(
            child: ActionButton(
              text: 'تعديل',
              icon: Icons.edit_rounded,
              baseColor: Colors.blueAccent,
              onPressed: edit,
              fontSize: value,
              compact: tightH,
            ),
          ),
        ),
        const Spacer(),
        Flexible(
          child: FittedBox(
            child: ActionButton(
              text: 'حذف',
              icon: Icons.delete_rounded,
              baseColor: Colors.redAccent,
              onPressed: del,
              fontSize: value,
              compact: tightH,
            ),
          ),
        ),
      ],
    );
  }
}

class ActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color baseColor;
  final VoidCallback onPressed;
  final double? fontSize;
  final bool compact;

  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.baseColor,
    required this.onPressed,
    this.fontSize,
    this.compact = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final f = (widget.fontSize ?? 13).clamp(10, 14).toDouble();
    final bgColor = hovering
        ? widget.baseColor
        : widget.baseColor.withOpacity(0.10);
    final borderColor = hovering
        ? widget.baseColor.withOpacity(0.00)
        : widget.baseColor.withOpacity(0.28);
    final fgColor = hovering ? Colors.white : widget.baseColor;
    final scale = hovering ? 1.02 : 1.0;
    final elevation = hovering ? 3.0 : 0.0;
    const duration = Duration(milliseconds: 140);

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: AnimatedScale(
        scale: scale,
        duration: duration,
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          elevation: elevation,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            hoverColor: widget.baseColor.withOpacity(0.08),
            splashColor: widget.baseColor.withOpacity(0.18),
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                vertical: widget.compact ? 6 : 8,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color: widget.baseColor.withOpacity(0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : const [],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: fgColor, size: f + 3),
                    const SizedBox(width: 4),
                    Text(
                      widget.text,
                      maxLines: 1,
                      style: TextStyle(
                        color: fgColor,
                        fontWeight: FontWeight.w600,
                        fontSize: f,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
