import 'theme_color_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/theme/theme_controller.dart';
import 'package:bayaa_pos/shared/layout/layout_tokens.dart';

class AppearanceCard extends StatelessWidget {
  const AppearanceCard({super.key});
  static const _labels = <String, List<String>>{
    'primary': ['Primary', 'اللون الرئيسي'],
    'secondary': ['Buttons & links', 'الأزرار والروابط'],
    'accent': ['Accent', 'اللون المميز'],
    'sidebar': ['Navigation', 'القائمة الجانبية'],
    'background': ['Page background', 'خلفية الصفحات'],
    'surface': ['Cards & surfaces', 'البطاقات والأسطح'],
  };
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = ThemeController.instance;
    return ListenableBuilder(
        listenable: theme,
        builder: (context, _) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.palette_outlined,
                          color: AppColors.secondaryColor),
                      const SizedBox(width: 12),
                      Text(
                          arabic
                              ? 'المظهر وألوان الواجهة'
                              : 'Appearance & colors',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 17))
                    ]),
                    OutlinedButton.icon(
                        onPressed: theme.reset,
                        icon: const Icon(Icons.restart_alt, size: 18),
                        label: Text(arabic
                            ? 'استعادة ألوان بياع'
                            : 'Reset Bayaa colors')),
                  ]),
              const SizedBox(height: 8),
              Text(
                  arabic
                      ? 'ألوانك الأصلية هي الإعداد الافتراضي. التخصيص للمعاينة فقط.'
                      : 'Your original palette is the default. Customization is preview-only.',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.mutedColor)),
              const SizedBox(height: 20),
              AdaptiveColumns(
                  minWidth: 220,
                  maxColumns: 3,
                  children: _labels.entries.map((entry) {
                    final color = theme.color(entry.key);
                    return OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(14),
                            side: BorderSide(color: AppColors.borderColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () => _editColor(
                            context, entry.key, entry.value[arabic ? 1 : 0]),
                        child: Row(children: [
                          Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                  color: color,
                                  border:
                                      Border.all(color: AppColors.borderColor),
                                  borderRadius: BorderRadius.circular(8))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(entry.value[arabic ? 1 : 0],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 12)),
                                const SizedBox(height: 3),
                                Text(_hex(color),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.mutedColor,
                                        fontSize: 10))
                              ])),
                          Icon(Icons.edit_outlined,
                              size: 16, color: AppColors.mutedColor)
                        ]));
                  }).toList()),
            ])));
  }

  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  Future<void> _editColor(
      BuildContext context, String role, String title) async {
    final selected = await showDialog<Color>(
        context: context,
        builder: (_) => ThemeColorDialog(
            title: title, color: ThemeController.instance.color(role)));
    if (selected != null) ThemeController.instance.update(role, selected);
  }
}
