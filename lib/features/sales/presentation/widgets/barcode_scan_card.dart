import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BarcodeScanCard extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;

  final Function(String)? onChanged;

  const BarcodeScanCard({
    super.key,
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.kPrimaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.kPrimaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'امسح الباركود أو ابحث عن منتج...',
                  hintStyle: TextStyle(color: AppColors.mutedColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
