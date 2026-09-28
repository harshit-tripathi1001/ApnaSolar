import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

/// Welcome Screen (Stitch: 66bff08a3f0d44c18dcdd8c1815cee16)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spaceMd),
              // Top Brand Pill
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: AppRadii.full,
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadowTinted,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wb_sunny_rounded,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: AppSpacing.spaceXs + 2),
                          Text(
                            'SURYAGHAR',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: AppRadii.full,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.onSecondaryFixed,
                          ),
                          const SizedBox(width: AppSpacing.spaceXs),
                          Text(
                            'PM Surya Ghar Ready',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSecondaryFixed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),

              // Hero Visual Card
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadii.lg,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryContainer,
                            Color(0xFF0F3628),
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.solar_power_rounded,
                            size: 80,
                            color: Color(0x33B9EED5),
                          ),
                          Positioned(
                            bottom: AppSpacing.spaceMd,
                            left: AppSpacing.spaceMd,
                            right: AppSpacing.spaceMd,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest
                                    .withValues(alpha: 0.95),
                                borderRadius: AppRadii.full,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppColors.tertiaryFixed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.bolt,
                                      size: 16,
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.spaceSm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Est. Rooftop Value',
                                          style: AppTypography.labelMd.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          'Up to ₹40,000 / yr savings',
                                          style: AppTypography.labelLg.copyWith(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.energy_savings_leaf,
                                    size: 18,
                                    color: AppColors.secondaryFresh,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),

              // Trust Ribbon
              Wrap(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainerLight,
                      borderRadius: AppRadii.full,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.roofing,
                          size: 16,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '18,400+ Indian roofs illuminated',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceSm),

              // Headline
              Text(
                'Know your roof.\nKnow your savings.',
                style: AppTypography.headlineLgMobile.copyWith(
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceXs),
              Text(
                'See what solar looks like for your home in under 2 minutes.',
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),

              // Quick Micro Benefits
              Row(
                children: [
                  _benefitTile(
                    icon: Icons.satellite_alt_rounded,
                    title: 'AI Roof Scan',
                    subtitle: 'No ladders',
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  _benefitTile(
                    icon: Icons.account_balance_rounded,
                    title: 'Govt. Subsidy',
                    subtitle: 'Direct DBT',
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  _benefitTile(
                    icon: Icons.savings_rounded,
                    title: 'Zero Upfront',
                    subtitle: 'Easy EMI',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceLg),

              // Primary CTA
              AppButton(
                label: 'Get Started',
                subtitle: 'Check Rooftop Solar & Subsidies',
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () => _showGetStartedSheet(context),
              ),
              const SizedBox(height: AppSpacing.spaceSm),

              // Secondary Sign-in Link
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                child: Text(
                  'Already have an account? Sign In',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),

              // Footer Assurance
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.spaceXs),
                  Flexible(
                    child: Text(
                      'MNRE Accredited • 25-Year Panel Warranty',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
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
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppColors.primaryContainer),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            Text(
              title,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.outline,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showGetStartedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: AppRadii.full,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Begin Your Solar Journey',
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Calculate rooftop potential, unlock central PM Surya Ghar subsidies, and save up to 90% on electricity.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Create Account (Primary)
            AppButton(
              label: 'Create Account',
              subtitle: 'New to ApnaSolar? Start here',
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.register);
              },
            ),
            const SizedBox(height: 12),

            // Option 2: Sign In (Secondary)
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.login);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: AppRadii.full),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.login_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sign In with Existing Account',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Option 3: Explore as Guest
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await AuthService().signInAnonymously();
                } catch (e) {
                  debugPrint('Anonymous sign-in note: $e');
                }
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.confirmLocation,
                    (route) => false,
                  );
                }
              },
              child: Text(
                'Explore as Guest (Instant Access)',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
