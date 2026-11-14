import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'loading/shimmer.dart';
import 'loading/skeleton.dart';

/// Versatile image renderer supporting:
/// - Assets (`assets/...`)
/// - Network images (`http://...` or `https://...`)
/// - Local file paths (`/path/...` or `C:\...`)
/// - Graceful loading and error states with shimmer/fallback
class AssetImageView extends StatelessWidget {
  const AssetImageView({
    super.key,
    required this.path,
    required this.width,
    required this.height,
    required this.fallback,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  final String? path;
  final double width;
  final double height;
  final Widget fallback;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imagePath = path?.trim();
    if (imagePath == null || imagePath.isEmpty) {
      return _wrap(fallback);
    }

    final isNetwork =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    final isAsset = imagePath.startsWith('assets/');

    Widget imageWidget;
    if (isNetwork) {
      final reduceMotion = MediaQuery.disableAnimationsOf(context);
      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth:
            width.isFinite && width > 0 ? (width * pixelRatio).round() : null,
        memCacheHeight: height.isFinite && height > 0
            ? (height * pixelRatio).round()
            : null,
        fadeInDuration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
        fadeOutDuration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
        placeholder: (_, __) => Shimmer(
            child: SkeletonBox(
                width: width, height: height, radius: borderRadius)),
        errorWidget: (_, __, ___) => fallback,
      );
    } else if (isAsset) {
      imageWidget = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else if (!kIsWeb) {
      // Local disk file
      try {
        final file = File(imagePath);
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback,
        );
      } catch (_) {
        imageWidget = fallback;
      }
    } else {
      imageWidget = fallback;
    }

    return _wrap(imageWidget);
  }

  Widget _wrap(Widget child) => SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: child,
        ),
      );
}
