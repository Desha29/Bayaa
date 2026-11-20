import 'package:flutter/material.dart';
import 'package:bayaa_pos/features/products/presentation/models/product_view_data.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/widgets/asset_image_view.dart';

/// A sleek, high-conversion POS product card with prominent image, price, stock indicators,
/// and smooth add-to-cart popup animation.
class PosProductTile extends StatefulWidget {
  const PosProductTile({
    super.key,
    required this.product,
    required this.onSelected,
  });

  final ProductViewData product;
  final VoidCallback onSelected;

  @override
  State<PosProductTile> createState() => _PosProductTileState();
}

class _PosProductTileState extends State<PosProductTile> {
  bool _isHovered = false;
  bool _tapped = false;

  void _handleTap() {
    widget.onSelected();
    setState(() => _tapped = true);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _tapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final product = widget.product;
    final stock = product.quantity > 0;
    final isLowStock = stock && product.quantity <= product.minQuantity;

    final stockColor = !stock
        ? AppColors.errorColor
        : isLowStock
            ? AppColors.warningColor
            : AppColors.successColor;

    final stockLabel = !stock
        ? (ar ? 'غير متوفر' : 'Out of stock')
        : isLowStock
            ? (ar ? 'متبقي ${product.quantity}' : '${product.quantity} left')
            : (ar
                ? '${product.quantity} متاح'
                : '${product.quantity} in stock');

    return AnimatedScale(
      scale: _tapped ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: stock ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _tapped
                  ? AppColors.primaryColor
                  : _isHovered && stock
                      ? AppColors.primaryColor.withOpacity(0.55)
                      : AppColors.borderColor.withOpacity(0.9),
              width: _tapped || (_isHovered && stock) ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _tapped
                    ? AppColors.primaryColor.withOpacity(0.18)
                    : _isHovered && stock
                        ? AppColors.primaryColor.withOpacity(0.08)
                        : const Color(0xFF0F172A).withOpacity(0.025),
                blurRadius: _tapped || (_isHovered && stock) ? 12 : 6,
                offset: Offset(0, _tapped || (_isHovered && stock) ? 4 : 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: stock ? _handleTap : null,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top: Image area with badge
                      Expanded(
                        flex: 11,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: const Color(0xFFF8FAFC),
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: AssetImageView(
                                  path: product.imagePath,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                  borderRadius: 10,
                                  fallback: Center(
                                    child: Icon(
                                      Icons.inventory_2_outlined,
                                      size: 36,
                                      color:
                                          AppColors.mutedColor.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Stock indicator chip overlay
                            PositionedDirectional(
                              top: 7,
                              start: 7,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6.5, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: stockColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: stockColor.withOpacity(0.28)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: stockColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      stockLabel,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: stockColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Add action icon button
                            if (stock)
                              PositionedDirectional(
                                bottom: 6,
                                end: 6,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: _tapped || _isHovered
                                        ? AppColors.primaryColor
                                        : AppColors.surfaceColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _tapped
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    size: 18,
                                    color: _tapped || _isHovered
                                        ? Colors.white
                                        : AppColors.primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Bottom: Info area
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: stock
                                          ? AppColors.textPrimary
                                          : AppColors.mutedColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.mutedColor,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${product.price.toStringAsFixed(2)} ${AppLocalizations.of(context).currencyEg}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                  color: stock
                                      ? AppColors.primaryColor
                                      : AppColors.mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Smooth popup badge when product is added to cart
                  if (_tapped)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _tapped ? 1.0 : 0.0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor
                                        .withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 5),
                                  Text(
                                    ar ? 'أضيف للسلة +1' : 'Added +1',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
