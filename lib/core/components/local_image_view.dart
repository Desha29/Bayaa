import 'dart:io';

import 'package:flutter/material.dart';

class LocalImageView extends StatelessWidget {
  const LocalImageView({
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
    final hasImage = imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync();

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: hasImage
            ? Image.file(
                File(imagePath),
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (_, __, ___) => fallback,
              )
            : fallback,
      ),
    );
  }
}
