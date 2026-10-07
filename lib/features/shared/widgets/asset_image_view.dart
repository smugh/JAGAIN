import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Reusable widget to display asset images, supporting:
/// 1. Bundled asset images (assets/images/...)
/// 2. Local device file images from Camera or Gallery (File(...))
/// 3. Web blob / network URLs
class AssetImageWidget extends StatelessWidget {
  const AssetImageWidget({
    required this.imagePath,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.borderRadius,
  });

  final String? imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget content;
    final path = imagePath;

    if (path == null || path.trim().isEmpty) {
      content = placeholder ?? _defaultPlaceholder(context);
    } else if (path.startsWith('assets/')) {
      content = Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? _defaultPlaceholder(context),
      );
    } else if (kIsWeb || path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
      content = Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? _defaultPlaceholder(context),
      );
    } else {
      content = Image.file(
        File(path),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? _defaultPlaceholder(context),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }
    return content;
  }

  Widget _defaultPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark ? JagainColors.darkSurface : const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
          size: (width != null && width! < 60) ? 20 : 32,
        ),
      ),
    );
  }
}
