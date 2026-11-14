import 'package:flutter/material.dart';

/// A package-free shimmer with reduced-motion support.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});
  final Widget child;
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1450));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
    } else {
      _animation.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
        animation: _animation,
        child: widget.child,
        builder: (context, child) => ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment(-3 + _animation.value * 6, 0),
                  end: Alignment(-1 + _animation.value * 6, 0),
                  colors: const [
                    Color(0x00FFFFFF),
                    Color(0xA6FFFFFF),
                    Color(0x00FFFFFF)
                  ],
                ).createShader(bounds),
            child: child));
  }
}
