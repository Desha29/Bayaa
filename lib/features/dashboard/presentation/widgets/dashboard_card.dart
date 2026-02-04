// ignore_for_file: deprecated_member_use


import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_cubit.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_states.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_states.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';

class DashboardCard extends StatefulWidget {
  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeOut,
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.04))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.6)
                  : AppColors.borderColor,
              width: 1.3,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.25),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: widget.color.withOpacity(0.15),
            highlightColor: Colors.transparent,
            onTap: widget.onTap,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 50),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: _isHovered
                                    ? [
                                        BoxShadow(
                                          color: widget.color.withOpacity(0.4),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: widget.color.withOpacity(0.15),
                                child: Icon(
                                  widget.icon,
                                  color: widget.color,
                                  size: 24,
                                ),
                              ),
                            ),
                            (widget.title == 'التنبيهات')
                                ? BlocBuilder<NotificationsCubit, NotificationsStates>(
                                    builder: (context, state) {
                                      final count = getIt<NotificationsCubit>().total;
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.errorColor,
                                        ),
                                        child: Text(
                                          count.toString(),
                                          style: const TextStyle(
                                            color: AppColors.backgroundColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox(),
                            (widget.title == 'المنتجات')
                                ? BlocBuilder<ProductCubit, ProductStates>(
                                    builder: (context, state) {
                                      final count = getIt<ProductCubit>().products.length;
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.errorColor,
                                        ),
                                        child: Text(
                                          count.toString(),
                                          style: const TextStyle(
                                            color: AppColors.backgroundColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox(),
                            (widget.title == 'المنتجات الناقصة')
                                ? BlocBuilder<StockCubit, StockStates>(
                                    builder: (context, state) {
                                      final count = getIt<StockCubit>().totalCount;
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.errorColor,
                                        ),
                                        child: Text(
                                          count.toString(),
                                          style: const TextStyle(
                                            color: AppColors.backgroundColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: FittedBox(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15, // Reduced from 18
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: FittedBox(
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
