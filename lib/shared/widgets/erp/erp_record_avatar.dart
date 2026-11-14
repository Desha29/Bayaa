import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';

class ErpRecordAvatar extends StatelessWidget {
  const ErpRecordAvatar(
      {super.key, required this.tag, required this.icon, this.size = 44});
  final String tag;
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return HeroMode(
            enabled: !MediaQuery.disableAnimationsOf(context),
            child: Hero(
                tag: tag,
                child: Material(
                    color: Colors.transparent,
                    child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                            color:
                                AppColors.secondaryColor.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon,
                            color: AppColors.secondaryColor,
                            size: size * .44)))));
      });
}
