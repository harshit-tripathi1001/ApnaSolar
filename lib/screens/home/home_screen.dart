import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

/// Home Dashboard Screen (Stitch: 9da40d1c6d8d4b11af78ee7a7f19f23c)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 0,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spaceSm),
            // Header Location & Solar Day Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
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
                      Text(
                        'Indiranagar, Bengaluru',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed.withValues(alpha: 0.5),
                    borderRadius: AppRadii.full,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wb_sunny,
                        size: 14,
                        color: AppColors.onTertiaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'High Sun Day',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.onTertiaryFixedVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Greeting
            Text(
              'Good morning, Ramesh 👋',
              style: AppTypography.headlineLgMobile.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Clear skies over your terrace today. Ready to turn sun into real savings?',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Hero Rooftop Valuation Card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: const BorderRadius.vertical(
                        top: AppRadii.rLg,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF164A38), Color(0xFF0D3124)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest
                                    .withValues(alpha: 0.9),
                                borderRadius: AppRadii.full,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '1,240 sq ft Terraced Roof',
                                    style: AppTypography.labelMd.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryFixed,
                                borderRadius: AppRadii.full,
                              ),
                              child: Text(
                                'Grade-A Solar Zone',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSecondaryFixed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Bangalore East Grid Connected',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: AppSpacing.cardPaddingLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ESTIMATED MONTHLY VALUE',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: AppRadii.full,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    size: 12,
                                    color: AppColors.onSecondaryContainer,
                                  ),
                                  Text(
                                    '85% bill cut',
                                    style: AppTypography.labelMd.copyWith(
                                      color: AppColors.onSecondaryContainer,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Your roof saves ',
                              style: AppTypography.headlineSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '₹3,350',
                              style: AppTypography.statCounter.copyWith(
                                color: AppColors.primary,
                                fontSize: 34,
                              ),
                            ),
                            Text(
                              ' / mo',
                              style: AppTypography.bodyLg.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spaceSm),
                        Text(
                          'Covers roughly ₹40,200 annually in BESCOM power bills with standard PM Surya Ghar subsidy.',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceMd),
                        AppButton(
                          label: 'Check My Solar Potential',
                          leadingIcon: Icons.solar_power_rounded,
                          trailingIcon: Icons.arrow_forward_rounded,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.confirmLocation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Quick Actions Trio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quick Actions', style: AppTypography.headlineSm),
                Text(
                  '1-Tap Fast Track',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Row(
              children: [
                _quickAction(
                  context,
                  icon: Icons.document_scanner_rounded,
                  title: 'Scan Bill',
                  subtitle: 'Instant OCR',
                  bg: AppColors.secondaryContainer,
                  route: AppRoutes.billScanning,
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                _quickAction(
                  context,
                  icon: Icons.calculate_rounded,
                  title: 'Subsidy Check',
                  subtitle: '₹78,000 Direct',
                  bg: AppColors.tertiaryFixed,
                  route: AppRoutes.subsidyPayback,
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                _quickAction(
                  context,
                  icon: Icons.forum_rounded,
                  title: 'Talk to Pro',
                  subtitle: 'Kannada/Eng',
                  bg: AppColors.primaryFixed,
                  route: AppRoutes.nearbyInstallers,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // PM Surya Ghar Banner
            Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadii.lg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: AppColors.onSecondaryFixed,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'PM Surya Ghar Yojana',
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: AppColors.secondaryFixed,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Eligible for direct bank transfer subsidy up to ₹78,000 for your 3kW installation.',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.primaryFixedDim,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),

            // Neighborhood Impact
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.forest_rounded,
                          size: 22,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(height: AppSpacing.spaceSm),
                        Text(
                          '142',
                          style: AppTypography.headlineMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Trees planted offset',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.savings_rounded,
                          size: 22,
                          color: AppColors.onTertiaryContainer,
                        ),
                        const SizedBox(height: AppSpacing.spaceSm),
                        Text(
                          '₹9.8 L',
                          style: AppTypography.headlineMd.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '25-Yr projected gain',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bg,
    required String route,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: AppRadii.md,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: AppRadii.md,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowTinted,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: AppColors.primaryContainer),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: AppTypography.labelMd.copyWith(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
