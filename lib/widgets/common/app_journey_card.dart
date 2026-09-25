import 'package:flutter/material.dart';

import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_card.dart';
import 'status_badge.dart';

/// Progress journey card showing current user stage and next milestone matching Stitch.
class AppJourneyCard extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double progressPercent;
  final String completedMilestone;
  final String nextMilestone;
  final VoidCallback? onTap;

  const AppJourneyCard({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.progressPercent,
    required this.completedMilestone,
    required this.nextMilestone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.standard,
      padding: AppSpacing.cardPadding,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.nature_people,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Text(
                    'Your Solar Journey',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: 'Step $currentStep of $totalSteps',
                variant: StatusBadgeVariant.neutral,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Animated Progress Bar
          ClipRRect(
            borderRadius: AppRadii.full,
            child: Container(
              height: 10,
              color: AppColors.surfaceContainer,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progressPercent.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: AppRadii.full,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    completedMilestone,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text.rich(
                TextSpan(
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  children: [
                    const TextSpan(text: 'Next: '),
                    TextSpan(
                      text: nextMilestone,
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
