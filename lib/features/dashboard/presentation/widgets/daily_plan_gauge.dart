import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DailyPlanGauge extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final int invoicesCount;
  final int invoicesTarget;
  final double currentSales;
  final double salesTarget;
  final String currency;

  const DailyPlanGauge({
    super.key,
    required this.percentage,
    required this.invoicesCount,
    required this.invoicesTarget,
    required this.currentSales,
    required this.salesTarget,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final pctClamped = percentage.clamp(0.0, 1.0);
    final displayPercent = (pctClamped * 100).toInt();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side breakdown
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricRow(
                label: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'فواتير تم إنجازها'
                    : 'Invoices processed',
                current: '$invoicesCount',
                target: '$invoicesTarget',
                progress: invoicesTarget > 0 ? (invoicesCount / invoicesTarget).clamp(0.0, 1.0) : 0.0,
                color: AppColors.secondaryColor,
              ),
              const SizedBox(height: 16),
              _buildMetricRow(
                label: Localizations.localeOf(context).languageCode == 'ar'
                    ? 'المبيعات المستهدفة'
                    : 'Sales target',
                current: currentSales.toStringAsFixed(0),
                target: '${salesTarget.toStringAsFixed(0)} $currency',
                progress: salesTarget > 0 ? (currentSales / salesTarget).clamp(0.0, 1.0) : 0.0,
                color: AppColors.successColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        // Right side Radial semi-circle Gauge
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 90,
                width: 140,
                child: CustomPaint(
                  painter: _SemiCircleGaugePainter(progress: pctClamped),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.thumb_up_alt_rounded,
                              size: 16,
                              color: AppColors.accentColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$displayPercent%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0%', style: TextStyle(fontSize: 10, color: AppColors.mutedColor, fontWeight: FontWeight.w600)),
                    Text('100%', style: TextStyle(fontSize: 10, color: AppColors.mutedColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String current,
    required String target,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.mutedColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              current,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              ' / $target',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.borderColor.withOpacity(0.6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _SemiCircleGaugePainter extends CustomPainter {
  final double progress;

  _SemiCircleGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    // Background track arc (180 degrees from pi to 2*pi)
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Active progress arc
    if (progress > 0) {
      final sweepAngle = math.pi * progress;
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [
            AppColors.successColor,
            AppColors.secondaryColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCircleGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
