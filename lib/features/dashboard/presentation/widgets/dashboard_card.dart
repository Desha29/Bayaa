// ignore_for_file: deprecated_member_use


import 'package:crazy_phone_pos/features/products/presentation/cubit/product_cubit.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_cubit.dart';
import 'package:crazy_phone_pos/features/products/presentation/cubit/product_states.dart';
import 'package:crazy_phone_pos/features/stock/presentation/cubit/stock_states.dart';
import 'package:crazy_phone_pos/features/notifications/presentation/cubit/notifications_states.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_cubit.dart';
import 'package:crazy_phone_pos/features/auth/presentation/cubit/user_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../invoice/presentation/cubit/invoice_cubit.dart';
import '../../../invoice/presentation/cubit/invoice_state.dart';
import '../../../arp/data/repositories/session_repository_impl.dart';

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceColor,
              _isHovered 
                  ? widget.color.withOpacity(0.02) 
                  : AppColors.surfaceColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? widget.color.withOpacity(0.3)
                : AppColors.borderColor,
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: widget.color.withOpacity(0.1),
            highlightColor: widget.color.withOpacity(0.05),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color.withOpacity(0.1),
                              widget.color.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      // Badge position for stats
                      (widget.title == 'التنبيهات')
                          ? BlocBuilder<NotificationsCubit, NotificationsStates>(
                              builder: (context, state) {
                                final count = getIt<NotificationsCubit>().total;
                                return _buildBadge(count);
                              },
                            )
                          : (widget.title == 'المنتجات')
                              ? BlocBuilder<ProductCubit, ProductStates>(
                                  builder: (context, state) {
                                    final count = getIt<ProductCubit>().products.length;
                                    return _buildBadge(count);
                                  },
                                )
                              : (widget.title == 'المنتجات الناقصة')
                                  ? BlocBuilder<StockCubit, StockStates>(
                                      builder: (context, state) {
                                        final count = getIt<StockCubit>().totalCount;
                                        return _buildBadge(count);
                                      },
                                    )
                                  : (widget.title == 'المبيعات')
                                      ? BlocBuilder<InvoiceCubit, InvoiceState>(
                                          bloc: getIt<InvoiceCubit>(),
                                          builder: (context, state) {
                                            final count = state.sales.where((s) => !s.isRefund).length;
                                            return _buildBadge(count);
                                          },
                                        )
                                      : (widget.title == 'الفواتير')
                                          ? BlocBuilder<InvoiceCubit, InvoiceState>(
                                              bloc: getIt<InvoiceCubit>(),
                                              builder: (context, state) {
                                                final count = state.sales.length;
                                                return _buildBadge(count);
                                              },
                                            )
                                          : (widget.title == 'ملخص المخزون')
                                              ? BlocBuilder<ProductCubit, ProductStates>(
                                                  bloc: getIt<ProductCubit>(),
                                                  builder: (context, state) {
                                                    final count = getIt<ProductCubit>().categories.length;
                                                    return _buildBadge(count);
                                                  },
                                                )
                                              : (widget.title == 'التحليلات والتقارير')
                                                  ? FutureBuilder<int>(
                                                      future: getIt<SessionRepositoryImpl>().getClosedSessions().then((s) => s.length),
                                                      builder: (context, snapshot) {
                                                        return _buildBadge(snapshot.data ?? 0);
                                                      },
                                                    )
                                                  : const SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedColor,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color,
            widget.color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
