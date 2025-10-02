import 'package:flutter/material.dart';

class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final Curve curve;
  final Key? animationKey;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
    this.beginOffset = const Offset(0, 0.04),
    this.curve = Curves.easeOutCubic,
    this.animationKey,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: animationKey,
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, t, _) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(beginOffset.dx * (1 - t) * 40, beginOffset.dy * (1 - t) * 40),
            child: child,
          ),
        );
      },
    );
  }
}

class FadeScale extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;
  final Curve curve;
  final Key? animationKey;

  const FadeScale({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
    this.beginScale = 0.985,
    this.curve = Curves.easeOut,
    this.animationKey,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: animationKey,
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, t, _) {
        final scale = beginScale + (1 - beginScale) * t;
        return Opacity(opacity: t, child: Transform.scale(scale: scale, child: child));
      },
    );
  }
}

class SubtleSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SubtleSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 240),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.985, end: 1.0).animate(anim),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
