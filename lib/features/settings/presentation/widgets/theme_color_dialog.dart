import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/shared/theme/theme_controller.dart';

class ThemeColorDialog extends StatefulWidget {
  const ThemeColorDialog({super.key, required this.title, required this.color});
  final String title;
  final Color color;
  @override
  State<ThemeColorDialog> createState() => _ThemeColorDialogState();
}

class _ThemeColorDialogState extends State<ThemeColorDialog> {
  late final _controller = TextEditingController(text: _hex(widget.color));
  String? _error;
  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final color in [
                ...ThemeController.defaults.values,
                const Color(0xFF0F766E),
                const Color(0xFF7C3AED),
                const Color(0xFFBE123C),
                const Color(0xFF111827)
              ])
                Tooltip(
                    message: _hex(color),
                    child: InkWell(
                        onTap: () => setState(() {
                              _controller.text = _hex(color);
                              _error = null;
                            }),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.borderColor))))),
            ]),
            const SizedBox(height: 24),
            TextField(
                controller: _controller,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                    labelText: 'HEX', hintText: '#1E3A8A', errorText: _error)),
          ]))),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(arabic ? 'إلغاء' : 'Cancel')),
        FilledButton(
            onPressed: () {
              final text = _controller.text.trim().replaceFirst('#', '');
              final parsed = int.tryParse(text, radix: 16);
              if (text.length != 6 || parsed == null) {
                setState(() => _error = arabic
                    ? 'أدخل لوناً من 6 رموز'
                    : 'Enter a six-digit color');
                return;
              }
              Navigator.pop(context, Color(0xFF000000 | parsed));
            },
            child: Text(arabic ? 'تطبيق' : 'Apply'))
      ],
    );
  }
}
