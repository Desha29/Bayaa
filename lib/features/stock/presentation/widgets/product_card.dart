// ignore_for_file: deprecated_member_use

import 'package:bayaa_pos/core/di/dependency_injection.dart';
import 'package:bayaa_pos/core/functions/messege.dart';
import 'package:bayaa_pos/features/auth/data/models/user_model.dart';
import 'package:bayaa_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bayaa_pos/core/constants/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import '../../../products/data/models/product_model.dart';
import 'priorty_chip.dart';
import 'status_chip.dart';

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
    final l10n = AppLocalizations.of(context);
    final product = widget.product;
    final isOut = product.quantity == 0;
    final isLow = product.quantity > 0 && product.quantity < product.minQuantity;
    
    final statusColor = isOut
        ? AppColors.errorColor
        : isLow
            ? AppColors.warningColor
            : AppColors.successColor;

    final cardBgColor = isOut
        ? AppColors.errorColor.withOpacity(0.02)
        : isLow
            ? AppColors.warningColor.withOpacity(0.02)
            : Colors.white;

    final cardBorderColor = _isHovered
        ? statusColor.withOpacity(0.5)
        : isOut
            ? AppColors.errorColor.withOpacity(0.24)
            : isLow
                ? AppColors.warningColor.withOpacity(0.24)
                : AppColors.borderColor.withOpacity(0.6);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cardBorderColor,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? statusColor.withOpacity(0.06)
                  : Colors.black.withOpacity(0.01),
              blurRadius: _isHovered ? 12 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Leading status indicator strip
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Product Name & Barcode
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PriorityChip(priority: product.priority),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(LucideIcons.barcode, size: 12, color: AppColors.mutedColor.withOpacity(0.8)),
                                  const SizedBox(width: 6),
                                  Text(
                                    product.barcode,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: AppColors.mutedColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Price Section
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.banknote, size: 12, color: AppColors.mutedColor.withOpacity(0.8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.sellingPrice,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: AppColors.mutedColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "${product.price.toStringAsFixed(2)} ${l10n.currencyEg}",
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quantity Section
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.package, size: 12, color: AppColors.mutedColor.withOpacity(0.8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.remaining,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: AppColors.mutedColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    l10n.unitCount(product.quantity),
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: statusColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusChip(isOut: isOut, isLow: isLow),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Restock Action
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 130,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: getIt<UserCubit>().currentUser.userType == UserType.manager
                                  ? widget.onRestock
                                  : disableMesg,
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isHovered
                                      ? AppColors.successColor
                                      : AppColors.successColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.successColor.withOpacity(0.24),
                                  ),
                                  boxShadow: _isHovered 
                                      ? [
                                          BoxShadow(
                                            color: AppColors.successColor.withOpacity(0.12),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.refreshCw,
                                      size: 13,
                                      color: _isHovered ? Colors.white : AppColors.successColor,
                                    ),
                                    const SizedBox(width: 6),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        l10n.restock,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: _isHovered ? Colors.white : AppColors.successColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  void disableMesg() {
    final l10n = AppLocalizations.of(context);
    MotionSnackBarWarning(context, l10n.errAccessDenied);
  }
}
