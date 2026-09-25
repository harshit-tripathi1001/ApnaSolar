import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';

/// Reusable metric card matching Stitch neighborhood impact & financial cards.
class AppMetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String tag;
  final String value;
  final String caption;
  final Color? valueColor;

  const AppMetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.tag,
    required this.value,
    required this.caption,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.standard,
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  tag,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.headlineMd.copyWith(
              color: valueColor ?? AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
