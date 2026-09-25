import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

enum AppCardVariant { standard, elevated, subtle, banner, glass }

/// Reusable card container matching Stitch design system specifications.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final AppCardVariant variant;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final bool withShadow;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.variant = AppCardVariant.standard,
    this.color,
    this.borderRadius,
    this.border,
    this.onTap,
    this.withShadow = true,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    BorderRadius effectiveRadius;
    Color effectiveColor;
    List<BoxShadow>? shadows;

    switch (variant) {
      case AppCardVariant.standard:
        effectiveRadius = borderRadius ?? AppRadii.md;
        effectiveColor = color ?? AppColors.surfaceContainerLowest;
        if (withShadow) {
          shadows = const [
            BoxShadow(
              color: Color(0x10164A38),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ];
        }
        break;
      case AppCardVariant.elevated:
        effectiveRadius = borderRadius ?? AppRadii.lg;
        effectiveColor = color ?? AppColors.surfaceContainerLowest;
        if (withShadow) {
          shadows = const [
            BoxShadow(
              color: Color(0x17164A38),
              blurRadius: 36,
              spreadRadius: -6,
              offset: Offset(0, 16),
            ),
          ];
        }
        break;
      case AppCardVariant.subtle:
        effectiveRadius = borderRadius ?? AppRadii.md;
        effectiveColor = color ?? AppColors.surfaceContainer;
        shadows = null;
        break;
      case AppCardVariant.banner:
        effectiveRadius = borderRadius ?? AppRadii.lg;
        effectiveColor = color ?? AppColors.primaryContainer;
        if (withShadow) {
          shadows = const [
            BoxShadow(
              color: Color(0x26003323),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ];
        }
        break;
      case AppCardVariant.glass:
        effectiveRadius = borderRadius ?? AppRadii.lg;
        effectiveColor =
            color ?? AppColors.surfaceContainerLowest.withValues(alpha: 0.85);
        if (withShadow) {
          shadows = const [
            BoxShadow(
              color: Color(0x0F164A38),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ];
        }
        break;
    }

    Widget content = Container(
      width: width ?? double.infinity,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveRadius,
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (variant == AppCardVariant.glass) {
      content = ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: content,
        ),
      );
    }

    if (onTap != null) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: shadows,
        ),
        child: Material(
          color: effectiveColor,
          shape: RoundedRectangleBorder(
            borderRadius: effectiveRadius,
            side: border?.top ?? BorderSide.none,
          ),
          clipBehavior: clipBehavior,
          child: InkWell(
            onTap: onTap,
            borderRadius: effectiveRadius,
            splashColor: AppColors.secondaryContainer.withValues(alpha: 0.3),
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
    }

    return content;
  }
}
