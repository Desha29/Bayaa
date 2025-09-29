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
    final isLowStock = qty > 0 && qty < min;
    final isOutOfStock = qty == 0;

    final padding = ResponsiveHelper.padding(context);
    final fontTitle = ResponsiveHelper.fontSize(
      context,
      mobile: 14,
      tablet: 16,
      desktop: 18,
    );
    final fontSmall = ResponsiveHelper.fontSize(
      context,
      mobile: 10,
      tablet: 11,
      desktop: 12,
    );
    final fontValue = ResponsiveHelper.fontSize(
      context,
      mobile: 12,
      tablet: 13,
      desktop: 14,
    );

    return Container(
      margin: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 280,
        maxHeight: 360,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isOutOfStock
              ? Colors.red.withOpacity(0.3)
              : isLowStock
              ? Colors.orange.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Title + Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    product['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: fontTitle,
                      color: const Color(0xff1e293b),
                      shadows: [
                        Shadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(fontSmall),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'كود: ${product['code']}',
              style: TextStyle(fontSize: fontSmall, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            /// Info Grid with Rounded Cards
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInfoItem(
                  'السعر',
                  '${product['price']}ج',
                  Icons.attach_money_rounded,
                  const Color(0xff059669),
                  fontSmall,
                  fontValue,
                ),
                _buildInfoItem(
                  'كمية',
                  product['qty'].toString(),
                  Icons.inventory_2_rounded,
                  qty == 0 ? Colors.red : const Color(0xff0fa2a9),
                  fontSmall,
                  fontValue,
                ),
                _buildInfoItem(
                  'حد أدنى',
                  product['min'].toString(),
                  Icons.trending_down_rounded,
                  const Color(0xfff59e0b),
                  fontSmall,
                  fontValue,
                ),
                _buildInfoItem(
                  'فئة',
                  product['category'] ?? '---',
                  Icons.category_rounded,
                  const Color(0xff8b5cf6),
                  fontSmall,
                  fontValue,
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Phone
            if (product['phone'] != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      size: fontSmall + 6,
                      color: Colors.blueGrey[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product['phone'],
                        style: TextStyle(
                          fontSize: fontSmall,
                          color: Colors.blueGrey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),

            /// Actions
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    text: 'تعديل',
                    icon: Icons.edit_rounded,
                    color: Colors.blueAccent,
                    onPressed: onEdit,
                    fontSize: fontValue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    text: 'حذف',
                    icon: Icons.delete_rounded,
                    color: Colors.redAccent,
                    onPressed: onDelete,
                    fontSize: fontValue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
    double fontLabel,
    double fontValue,
  ) {
    return Container(
      width: 75,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: fontValue + 5),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: fontLabel, color: Colors.grey[700]),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontValue,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double? fontSize;

  const _ActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final fSize = fontSize ?? 13;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: fSize + 5),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: fSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
