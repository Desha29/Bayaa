import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bayaa_pos/shared/theme/app_colors.dart';
import 'shimmer.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 16, this.radius = 8});
  final double? width;
  final double height;
  final double radius;
  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                color: AppColors.borderColor.withValues(alpha: .65),
                borderRadius: BorderRadius.circular(radius)));
      });
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 5});
  final int rows;
  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return Semantics(
            label: Localizations.localeOf(context).languageCode == 'ar'
                ? 'جار عرض الواجهة'
                : 'Loading interface',
            child: ExcludeSemantics(
                child: Shimmer(
                    child: Column(children: [
              for (var i = 0; i < rows; i++)
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      const SkeletonBox(width: 44, height: 44),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const SkeletonBox(width: 180),
                            const SizedBox(height: 8),
                            SkeletonBox(width: i.isEven ? 110 : 150, height: 12)
                          ])),
                      const SizedBox(width: 12),
                      const SkeletonBox(width: 56, height: 24)
                    ])),
            ]))));
      });
}

/// A short visual entrance, independent of any data/network operation.
class SkeletonReveal extends StatefulWidget {
  const SkeletonReveal({super.key, required this.child});
  final Widget child;
  @override
  State<SkeletonReveal> createState() => _SkeletonRevealState();
}

class _SkeletonRevealState extends State<SkeletonReveal> {
  bool _ready = false;
  Timer? _timer;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ready = true;
      return;
    }
    _timer ??= Timer(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Builder(builder: (context) {
        Theme.of(context);
        return AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            child: _ready
                ? widget.child
                : const SingleChildScrollView(child: SkeletonList()));
      });
}
