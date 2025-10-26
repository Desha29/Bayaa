import 'package:crazy_phone_pos/core/di/dependency_injection.dart';
import 'package:crazy_phone_pos/core/functions/messege.dart';
import 'package:crazy_phone_pos/features/auth/data/models/user_model.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../products/data/models/product_model.dart';
import 'priorty_chip.dart';
import 'status_chip.dart';

/// ---------------- Product Model ----------------


/// ---------------- Product Card ----------------

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onRestock;

  const ProductCard({
    super.key,
    required this.product,
    required this.onRestock,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOut = product.quantity == 0;
    final isLow = product.quantity > 0 && product.quantity < product.minQuantity;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isHovered ? 1.02 : 1.0,
        child: Padding(
          padding: ResponsiveHelper.padding(
            context,
            mobile: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tablet: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            desktop: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? Colors.blueAccent.withOpacity(0.5)
                    : isOut
                        ? Colors.red.withOpacity(0.3)
                        : isLow
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? Colors.black.withOpacity(0.12)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 16 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: ResponsiveHelper.padding(
                context,
                mobile: const EdgeInsets.all(10),
                tablet: const EdgeInsets.all(14),
                desktop: const EdgeInsets.all(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ✅ يمنع الـ overflow
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// -------- Header --------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ResponsiveHelper.fontSize(
                                    context,
                                    mobile: 14,
                                    tablet: 15,
                                    desktop: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'كود: ${product.barcode}',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.fontSize(
                                    context,
                                    mobile: 12,
                                    tablet: 13,
                                    desktop: 13,
                                  ),
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PriorityChip(priority: product.priority),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// -------- Quantity Info --------
                  Expanded(
                    // ✅ هنا يتمدد بشكل مرن جوا الكارت
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: _buildInfoRow(
                              context,
                              'الكمية الحالية:',
                              product.quantity.toString(),
                              isOut
                                  ? const Color(0xFFEF4444)
                                  : (isLow
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF10B981)),
                              bold: true,
                              valueSize: 16,
                            ),
                          ),
                          Flexible(
                            child: _buildInfoRow(
                              context,
                              'الحد الأدنى:',
                              product.minQuantity.toString(),
                              Colors.black,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// -------- Status & Action --------
                  Row(
                    children: [
                      Expanded(
                        child: StatusChip(isOut: isOut, isLow: isLow),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: getIt<UserCubit>().currentUser.userType ==
                                  UserType.manager
                              ? widget.onRestock
                              : disableMesg,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('إعادة التخزين'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void disableMesg() {
    MotionSnackBarWarning(context, "لا يوجد لديك صلاحيات");
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    bool bold = false,
    double valueSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                fontSize: valueSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
