import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/preview/branch_preview_controller.dart';

class BranchContextBar extends StatelessWidget {
  const BranchContextBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class BranchDataGate extends StatelessWidget {
  const BranchDataGate({super.key, required this.module});
  final String module;
  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final scope = BranchPreviewController.instance;
    return Center(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.visibility_off_outlined,
                  size: 40, color: AppColors.mutedColor),
              const SizedBox(height: 14),
              Text(
                  ar
                      ? 'هذا القسم مخفي في نطاق العرض الحالي'
                      : 'This section is hidden in the current view',
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(scope.label(ar),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mutedColor)),
              const SizedBox(height: 16),
              OutlinedButton(
                  onPressed: () =>
                      scope.setSectionVisible(scope.sectionFor(module)!, true),
                  child: Text(ar ? 'إظهار القسم' : 'Show section')),
            ])));
  }
}
