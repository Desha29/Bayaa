import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stock/presentation/cubit/stock_cubit.dart';
import '../../../stock/presentation/cubit/stock_states.dart';

class StockCapacityCard extends StatelessWidget {
  final VoidCallback onShowAll;

  const StockCapacityCard({super.key, required this.onShowAll});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.localeName == 'ar';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'حالة المخزون والتنبيهات' : 'Stock Status & Capacity',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: onShowAll,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    isArabic ? 'عرض الكل >' : 'Show all >',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          BlocBuilder<StockCubit, StockStates>(
            bloc: getIt<StockCubit>(),
            builder: (context, state) {
              final stockCubit = getIt<StockCubit>();
              final lowStockProducts = stockCubit.products
                  .where((p) => p.quantity <= p.minQuantity)
                  .toList();

              if (lowStockProducts.isEmpty) {
                // Show healthy stock message
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.successColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.checkCheck, color: AppColors.successColor, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isArabic ? 'المخزون في حالة ممتازة ومستقرة' : 'Inventory levels are optimal',
                        style: const TextStyle(
                          color: AppColors.successColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Display up to 4 items with progress bars (Behance Available Truck style)
              final displayList = lowStockProducts.take(4).toList();

              return Column(
                children: displayList.map((product) {
                  final qty = product.quantity;
                  final minQty = product.minQuantity > 0 ? product.minQuantity : 10;
                  final ratio = (qty / minQty).clamp(0.0, 1.0);
                  final percent = (ratio * 100).toInt();

                  final Color barColor = ratio <= 0.25
                      ? AppColors.errorColor
                      : ratio <= 0.6
                          ? AppColors.warningColor
                          : AppColors.successColor;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$qty / $minQty ($percent%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: barColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: AppColors.borderColor.withOpacity(0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
