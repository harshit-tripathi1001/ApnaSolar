import 'package:flutter/material.dart';

import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum StatusBadgeVariant { green, amber, primary, neutral, error }

/// Pill-shaped badge for statuses, tags, step milestones, and certifications.
class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final StatusBadgeVariant variant;
  final bool hasPulseDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = StatusBadgeVariant.green,
    this.hasPulseDot = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (variant) {
      case StatusBadgeVariant.green:
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        break;
      case StatusBadgeVariant.amber:
        bg = AppColors.tertiaryFixed;
        fg = AppColors.onTertiaryFixedVariant;
        break;
      case StatusBadgeVariant.primary:
        bg = AppColors.primaryFixed;
        fg = AppColors.onPrimaryFixed;
        break;
      case StatusBadgeVariant.neutral:
        bg = AppColors.surfaceContainer;
        fg = AppColors.onSurfaceVariant;
        break;
      case StatusBadgeVariant.error:
        bg = AppColors.errorContainer;
        fg = AppColors.onErrorContainer;
        break;
    }

    return Container(
      padding: AppSpacing.chipPadding,
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.full),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPulseDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.spaceXs + 2),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.spaceXs),
          ],
          Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
