import 'package:flutter/material.dart';

import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// Reusable card container using warm white surface and soft organic shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool withShadow;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.color,
    this.borderRadius,
    this.border,
    this.onTap,
    this.withShadow = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadii.lg;
    final effectiveColor = color ?? AppColors.surfaceContainerLowest;

    final boxDecoration = BoxDecoration(
      color: effectiveColor,
      borderRadius: effectiveRadius,
      border: border,
      boxShadow: withShadow
          ? const [
              BoxShadow(
                color: AppColors.shadowTinted,
                blurRadius: 24,
                spreadRadius: -4,
                offset: Offset(0, 8),
              ),
            ]
          : null,
    );

    if (onTap != null) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: boxDecoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: effectiveRadius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding,
      decoration: boxDecoration,
      child: child,
    );
  }
}
