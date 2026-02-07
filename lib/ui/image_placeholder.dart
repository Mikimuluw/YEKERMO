import 'package:flutter/material.dart';
import 'package:yekermo/shared/extensions/context_extensions.dart';
import 'package:yekermo/theme/radii.dart';

/// Standard image placeholder for restaurant cards, hero areas, and list thumbnails.
/// Uses theme surfaceContainerHighest and [AppRadii]; no custom styling.
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;

  /// If null, uses [AppRadii.br12]. Use [AppRadii.br16] for hero/card top.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: borderRadius ?? AppRadii.br12,
      ),
    );
  }
}
