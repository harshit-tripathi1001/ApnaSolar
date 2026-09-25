import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';

/// Quick Action button card matching Stitch's 3-column action launcher.
class AppQuickAction extends StatelessWidget {
  final IconData icon;
  final Color iconContainerColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AppQuickAction({
    super.key,
    required this.icon,
    required this.iconContainerColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.standard,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconContainerColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icon, size: 24, color: iconColor)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.labelMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
