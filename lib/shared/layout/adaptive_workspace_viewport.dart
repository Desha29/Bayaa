import 'package:flutter/material.dart';

/// Scroll short landscape windows instead of squeezing bounded panes to zero.
class AdaptiveWorkspaceViewport extends StatelessWidget {
  const AdaptiveWorkspaceViewport({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, size) {
        final minimum =
            540.0 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.5);
        if (size.maxHeight >= minimum) return child;
        return SingleChildScrollView(
            child:
                SizedBox(width: size.maxWidth, height: minimum, child: child));
      });
}
