import 'package:flutter/material.dart';
import 'package:crazy_phone_pos/core/components/app_logo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/settings/presentation/cubit/settings_states.dart';
import '../di/dependency_injection.dart';

class Logo extends StatefulWidget {
  const Logo({
    super.key,
    this.avatarRadius,
    this.isMobile,
  });

 
  final double? avatarRadius;
  final bool? isMobile;

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  late final AnimationController _logoCtl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _logoCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _logoCtl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.95, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_logoCtl);
    _logoCtl.forward();
  }

  @override
  void dispose() {
    _logoCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    final maxW = MediaQuery.of(context).size.width;
    final isMobile = widget.isMobile ?? maxW < 520;
    final avatarRadius = widget.avatarRadius ?? (isMobile ? 72.0 : 100.0);

    return Column(
      children: [
        AnimatedBuilder(
          animation: _logoCtl,
          builder: (context, _) {
            return FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Shimmer(
                  enabled: true,
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(avatarRadius),
                      child: AppLogo(
                        width: avatarRadius * 2,
                        height: avatarRadius * 2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<SettingsCubit, SettingsStates>( // Listen to settings changes
          bloc: getIt<SettingsCubit>(),
          builder: (context, state) {
             final store = getIt<SettingsCubit>().currentStoreInfo;
             final name = store?.name.isNotEmpty == true ? store!.name : 'Bayaa';
             final slogan  = 'نظام نقاط البيع الاحترافي';
             
             return Column(
               children: [
                 FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1,
                          fontSize: isMobile ? 18 : 24,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            slogan,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
               ],
             );
          },
        ),
      ],
    );
  }
}

// Lightweight shimmer used by Logo; self-contained.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return ShaderMask(
          shaderCallback: (rect) {
            final width = rect.width;
            final dx = (width + rect.height) * t - rect.height;
            return LinearGradient(
              begin: const Alignment(-1.0, 0.0),
              end: const Alignment(1.0, 0.0),
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.45),
                Colors.white.withOpacity(0.15),
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: GradientTranslation(dx),
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class GradientTranslation extends GradientTransform {
  const GradientTranslation(this.dx);
  final double dx;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.identity()..translate(dx, 0.0);
  }
}
