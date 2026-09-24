import 'package:flutter/material.dart';

import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, radiant, secondary, outline, ghost }

/// Reusable pill-shaped button adhering to ApnaSolar design guidelines.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final double? width;
  final double height;
  final String? subtitle;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.width,
    this.height = 54.0,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;
    List<BoxShadow> shadows = [];

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primaryContainer;
        foregroundColor = AppColors.onPrimary;
        shadows = const [
          BoxShadow(
            color: Color(0x33003323),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.radiant:
        backgroundColor = AppColors.tertiarySolar;
        foregroundColor = AppColors.onSurface;
        shadows = const [
          BoxShadow(
            color: Color(0x33F5C542),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ];
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.secondaryContainerLight;
        foregroundColor = AppColors.primaryContainer;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        borderSide = const BorderSide(
          color: AppColors.outlineVariant,
          width: 1.5,
        );
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.onSurfaceVariant;
        break;
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null && !isLoading) ...[
          Icon(leadingIcon, size: 20, color: foregroundColor),
          const SizedBox(width: AppSpacing.spaceSm),
        ],
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: subtitle != null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTypography.labelLg.copyWith(color: foregroundColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.labelMd.copyWith(
                      color: foregroundColor.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: AppSpacing.spaceSm),
          Icon(trailingIcon, size: 20, color: foregroundColor),
        ],
      ],
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppRadii.full,
        boxShadow: onPressed != null ? shadows : null,
      ),
      child: Material(
        color: onPressed != null
            ? backgroundColor
            : AppColors.surfaceContainerHighest,
        borderRadius: AppRadii.full,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.full,
          side: borderSide,
        ),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppRadii.full,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: content,
          ),
        ),
      ),
    );
  }
}
