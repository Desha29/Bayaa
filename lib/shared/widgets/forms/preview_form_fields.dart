import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'package:bayaa_pos/l10n/app_localizations.dart';

class AdaptiveFormRow extends StatelessWidget {
  const AdaptiveFormRow({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 480 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.4) {
          return Column(children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              children[i]
            ]
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 16),
            Expanded(child: children[i])
          ]
        ]);
      });
}

Widget buildPreviewTextField(BuildContext context,
        TextEditingController controller, String label, IconData icon,
        {TextInputType? keyboardType, bool readOnly = false}) =>
    PreviewTextField(
        controller: controller,
        label: label,
        icon: icon,
        keyboardType: keyboardType,
        readOnly: readOnly);

class PreviewTextField extends StatelessWidget {
  const PreviewTextField(
      {super.key,
      required this.controller,
      required this.label,
      required this.icon,
      this.keyboardType,
      this.readOnly = false});
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool readOnly;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
        readOnly: readOnly,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.primaryColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16)),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return l10n.fieldRequired;
          if (keyboardType == TextInputType.number &&
              double.tryParse(value.trim()) == null) {
            return l10n.enterValidNumber;
          }
          return null;
        });
  }
}
