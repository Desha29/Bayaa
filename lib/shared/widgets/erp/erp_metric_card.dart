import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'erp_view_spec.dart';

class ErpMetricCard extends StatelessWidget {
  const ErpMetricCard({super.key, required this.spec});
  final ErpMetricSpec spec;
  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(spec.label.of(context),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.mutedColor))),
                Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(spec.icon,
                        size: 19, color: AppColors.secondaryColor))
              ]),
              const SizedBox(height: 12),
              Text(spec.value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              if (spec.note != null) ...[
                const SizedBox(height: 5),
                Text(spec.note!.of(context),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.mutedColor,
                        fontSize: 11))
              ],
            ]));
      });
}
