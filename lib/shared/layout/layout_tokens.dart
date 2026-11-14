import 'package:flutter/material.dart';

/// All breakpoints are based on available content width, across platforms.
abstract final class LayoutTokens {
  static const compact = 600.0;
  static const medium = 1024.0;
  static const wide = 1440.0;
  static const contentMaxWidth = 1800.0;
  static const pageGap = 20.0;
  static const cardRadius = 16.0;

  static EdgeInsets pagePadding(double width) => EdgeInsets.all(width < compact
      ? 12
      : width < medium
          ? 20
          : 24);
  static int columns(double width, {double minWidth = 260, int max = 4}) =>
      (width / minWidth).floor().clamp(1, max);
}

class AdaptiveColumns extends StatelessWidget {
  const AdaptiveColumns(
      {super.key,
      required this.children,
      this.minWidth = 260,
      this.maxColumns = 4,
      this.spacing = 16});
  final List<Widget> children;
  final double minWidth;
  final int maxColumns;
  final double spacing;
  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return LayoutBuilder(builder: (context, size) {
          final count = LayoutTokens.columns(size.maxWidth,
              minWidth: minWidth, max: maxColumns);
          final width = (size.maxWidth - (count - 1) * spacing) / count;
          return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: children
                  .map((child) => SizedBox(width: width, child: child))
                  .toList());
        });
      });
}
