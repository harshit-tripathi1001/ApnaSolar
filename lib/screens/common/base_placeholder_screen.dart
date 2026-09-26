import 'package:flutter/material.dart';

import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/status_badge.dart';

import '../../app/routes.dart';

/// Clean, structured placeholder screen representing a Stitch screen instance.
class BasePlaceholderScreen extends StatelessWidget {
  final String title;
  final String stitchScreenId;
  final String description;
  final IconData icon;
  final String? nextRoute;
  final String? nextLabel;
  final String? propertyAddress;
  final List<Widget>? quickNavActions;

  const BasePlaceholderScreen({
    super.key,
    required this.title,
    required this.stitchScreenId,
    required this.description,
    required this.icon,
    this.nextRoute,
    this.nextLabel,
    this.propertyAddress,
    this.quickNavActions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTypography.headlineSm),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Return to Home',
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.home),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    label: 'Stitch Screen Ready',
                    icon: Icons.check_circle_outline,
                    variant: StatusBadgeVariant.green,
                  ),
                  StatusBadge(
                    label: 'Phase 1 Foundation',
                    variant: StatusBadgeVariant.amber,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              AppCard(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainerLight,
                        borderRadius: AppRadii.full,
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),
                    Text(
                      title,
                      style: AppTypography.headlineMd,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    Text(
                      description,
                      style: AppTypography.bodyMd,
                      textAlign: TextAlign.center,
                    ),
                    if (propertyAddress != null) ...[
                      const SizedBox(height: AppSpacing.spaceSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                          borderRadius: AppRadii.full,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                propertyAddress!,
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.spaceMd),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadii.sm,
                      ),
                      child: Text(
                        'ID: $stitchScreenId',
                        style: AppTypography.labelMd.copyWith(
                          fontFamily: 'monospace',
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (nextRoute != null) ...[
                const SizedBox(height: AppSpacing.spaceLg),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, nextRoute!),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(nextLabel ?? 'Continue to Next Step'),
                      const SizedBox(width: AppSpacing.spaceSm),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
              if (quickNavActions != null && quickNavActions!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.spaceLg),
                Text('Screen Navigation Flow', style: AppTypography.labelLg),
                const SizedBox(height: AppSpacing.spaceSm),
                ...quickNavActions!,
              ],
              if (nextRoute != AppRoutes.home) ...[
                const SizedBox(height: AppSpacing.spaceSm),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false),
                  icon: const Icon(Icons.dashboard_rounded, size: 16),
                  label: const Text('Return to Home Dashboard'),
                ),
              ],
              const SizedBox(height: AppSpacing.spaceXl),
            ],
          ),
        ),
      ),
    );
  }
}
