import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class DailyTargetGauge extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final int invoicesCount;
  final int invoicesTarget;
  final double currentSales;
  final double salesTarget;
  final String currency;

  const DailyTargetGauge({
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
    Theme.of(context);
    final pctClamped = percentage.clamp(0.0, 1.0);
    final displayPercent = (pctClamped * 100).toInt();

    return LayoutBuilder(builder: (context, size) {
      final metrics = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricRow(
            label: Localizations.localeOf(context).languageCode == 'ar'
                ? 'فواتير تم إنجازها'
                : 'Invoices processed',
            current: '$invoicesCount',
            target: '$invoicesTarget',
            progress: invoicesTarget > 0
                ? (invoicesCount / invoicesTarget).clamp(0.0, 1.0)
                : 0.0,
            color: AppColors.secondaryColor,
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            label: Localizations.localeOf(context).languageCode == 'ar'
                ? 'المبيعات المستهدفة'
                : 'Sales target',
            current: currentSales.toStringAsFixed(0),
            target: '${salesTarget.toStringAsFixed(0)} $currency',
            progress: salesTarget > 0
                ? (currentSales / salesTarget).clamp(0.0, 1.0)
                : 0.0,
            color: AppColors.successColor,
          ),
        ],
      );
      final gauge = SizedBox(
          width: 160,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: math.max(
                    90.0, MediaQuery.textScalerOf(context).scale(18) + 50),
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
                            child: Icon(
                              Icons.thumb_up_alt_rounded,
                              size: 16,
                              color: AppColors.accentColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$displayPercent%',
                            style: TextStyle(
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
                  children: [
                    Text('0%',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedColor,
                            fontWeight: FontWeight.bold)),
                    Text('100%',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedColor,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ));
      if (size.maxWidth < 400 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.4) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              metrics,
              const SizedBox(height: 18),
              Center(child: gauge)
            ]);
      }
      return Row(children: [
        Expanded(child: metrics),
        const SizedBox(width: 18),
        gauge
      ]);
    });
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
          style: TextStyle(
            fontSize: 11.5,
            color: AppColors.mutedColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 2,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              current,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              ' / $target',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
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
        ..shader = LinearGradient(
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
