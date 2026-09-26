import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/solar_session_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_journey_card.dart';
import '../../widgets/common/app_metric_card.dart';
import '../../widgets/common/app_quick_action.dart';
import '../../widgets/common/status_badge.dart';

/// Home Dashboard Screen directly converted from the Google Stitch design
/// Stitch Project: 420246445353085452 / Screen: 9da40d1c6d8d4b11af78ee7a7f19f23c
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Stitch Hero rooftop image URL
  static const String _heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDRRmJ5hpubzWN3YDnVPcL8vQtTk9y050FDXyiwGuazTFflTHMe3IU7DAPNobww69EGJPLuWnmo3Ly4XnnaGEgIoNZ3egYP8EcpHaaNL_-aWc8eW7gU57ojmD3sGOJXbnIp6ZIRJHhSbYNcZTqd4_Qs4Y9n2n-zof7MhSfReBhhjgVmqgsfQkIbmyVPR1y-98U1C1LZI__k6wYvX2-RkN38qlCJdW_2wtTq7UZJUTTY2x1jvG4wHqc';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    SolarSessionState().addListener(_onSessionChanged);
    _animController.forward();
  }

  void _onSessionChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    SolarSessionState().removeListener(_onSessionChanged);
    _animController.dispose();
    super.dispose();
  }

  void _showWarrantyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: AppRadii.rLg),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: AppRadii.full,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Text(
                    '25-Year Protection Package',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              _warrantyItem(
                '25-Year Solar Panel Linear Output',
                'Guarantees minimum 84.8% peak generation efficiency in Year 25.',
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              _warrantyItem(
                '10-Year Inverter Replacement',
                'Zero-cost comprehensive coverage for hybrid/string inverters.',
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              _warrantyItem(
                '5-Year Complete Installation & Workmanship',
                'Covers rooftop mounting structures, weatherproofing, and cables.',
              ),
              const SizedBox(height: AppSpacing.spaceLg),
              AppButton(
                label: 'Got It',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _warrantyItem(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.secondary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margin,
              AppSpacing.spaceSm,
              AppSpacing.margin,
              108.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Location & Solar Condition Header Pills
                _buildTopHeaderPills(),
                const SizedBox(height: AppSpacing.spaceSm),

                // Greeting & Terrace Summary
                _buildGreetingSection(),
                const SizedBox(height: AppSpacing.spaceLg),

                // Hero Rooftop Valuation Card (Stitch: 780x3064 layout)
                _buildHeroRooftopCard(context),
                const SizedBox(height: AppSpacing.spaceLg),

                // Solar Journey Milestone Tracker (Stitch Step 2 of 5)
                AppJourneyCard(
                  currentStep: 2,
                  totalSteps: 5,
                  progressPercent: 0.4,
                  completedMilestone: 'Rooftop Measured',
                  nextMilestone: 'Subsidy Approval',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.aiRoofAnalysis),
                ),
                const SizedBox(height: AppSpacing.spaceLg),

                // Quick Actions 3-Column Fast Track Launcher
                _buildQuickActionsSection(context),
                const SizedBox(height: AppSpacing.spaceLg),

                // PM Surya Ghar Yojana DBT Subsidy Banner Card
                _buildPmSuryaGharBanner(context),
                const SizedBox(height: AppSpacing.spaceLg),

                // Neighborhood Environmental & Lifetime Gains
                _buildNeighborhoodImpact(),
                const SizedBox(height: AppSpacing.spaceLg),

                // 25-Year Manufacturer Warranty Sub-Card
                _buildWarrantyCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeaderPills() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Indiranagar, Bengaluru Location Pill
        Flexible(
          child: InkWell(
            borderRadius: AppRadii.full,
            onTap: () => Navigator.pushNamed(context, AppRoutes.confirmLocation),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadii.full,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A164A38),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 15,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${SolarSessionState().selectedProperty.locality}, ${SolarSessionState().selectedProperty.city}',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // High Sun Day Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.tertiaryFixed.withValues(alpha: 0.4),
            borderRadius: AppRadii.full,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wb_sunny,
                size: 15,
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
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Good morning, Ramesh',
              style: AppTypography.headlineLgMobile.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            const Text('👋', style: TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Clear skies over your terrace today. Ready to turn sun into real savings?',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroRooftopCard(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper Visual Graphic Area with Rooftop Imagery and Floating Badges
          SizedBox(
            height: 224,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Sunlit Bangalore home rooftop image with fallback gradient
                Image.network(
                  _heroImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildHeroFallbackImage(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildHeroFallbackImage();
                  },
                ),

                // Gradient Overlay matching Stitch: from-surface-container-lowest via-transparent to-black/10
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.surfaceContainerLowest,
                        AppColors.surfaceContainerLowest.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // Floating Top-Left Badge: 1,240 sq ft Terraced Roof with Live Pulsing Dot
                Positioned(
                  top: 14,
                  left: 14,
                  child: StatusBadge(
                    label: '1,240 sq ft Terraced Roof',
                    variant: StatusBadgeVariant.glass,
                    hasPulseDot: true,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Floating Top-Right Badge: Grade-A Solar Zone
                Positioned(
                  top: 14,
                  right: 14,
                  child: StatusBadge(
                    label: 'Grade-A Solar Zone',
                    variant: StatusBadgeVariant.secondaryFixed,
                    icon: Icons.energy_savings_leaf,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lower Hero Info & Call-To-Action Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spaceLg),
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
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StatusBadge(
                      label: '85% bill reduction',
                      variant: StatusBadgeVariant.green,
                      icon: Icons.bolt,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Big Monthly Value
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Your roof saves ',
                      style: AppTypography.headlineMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      '₹3,350',
                      style: AppTypography.statCounter.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 38,
                      ),
                    ),
                    Text(
                      ' / month',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Narrative with bold accent
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: const [
                      TextSpan(text: 'Covers roughly '),
                      TextSpan(
                        text: '₹40,200 annually',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' in BESCOM electricity power bills with standard PM Surya Ghar subsidy.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceLg),

                // Signature CTA matching Stitch: w-full min-h-[54px] rounded-full bg-primary
                AppButton(
                  label: 'Check My Solar Potential',
                  leadingIcon: Icons.solar_power,
                  leadingIconColor: AppColors.tertiaryFixed,
                  showTrailingArrowBadge: true,
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.confirmLocation),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroFallbackImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF164A38), Color(0xFF0B6D33), Color(0xFF382A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wb_sunny_rounded,
              size: 44,
              color: AppColors.tertiaryFixed.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 4),
            Text(
              'Sunlit Bengaluru Terrace',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.secondaryFixed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
            Expanded(
              child: AppQuickAction(
                icon: Icons.document_scanner,
                iconContainerColor: AppColors.secondaryContainer,
                iconColor: AppColors.onSecondaryContainer,
                title: 'Scan Bill',
                subtitle: 'Instant OCR',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.billScanning),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: AppQuickAction(
                icon: Icons.calculate,
                iconContainerColor: AppColors.tertiaryFixed,
                iconColor: AppColors.onTertiaryFixedVariant,
                title: 'Subsidy Check',
                subtitle: '₹78,000 Direct',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.subsidyPayback),
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: AppQuickAction(
                icon: Icons.forum,
                iconContainerColor: AppColors.primaryFixed,
                iconColor: AppColors.onPrimaryFixed,
                title: 'Talk to Pro',
                subtitle: 'In Kannada/Eng',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.nearbyInstallers),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPmSuryaGharBanner(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.banner,
      padding: AppSpacing.cardPadding,
      onTap: () => Navigator.pushNamed(context, AppRoutes.subsidyPayback),
      child: Stack(
        children: [
          // Background subtle decorative sun radial glow
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.workspace_premium,
                    size: 26,
                    color: AppColors.onSecondaryFixed,
                  ),
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
                          size: 16,
                          color: AppColors.secondaryFixed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Eligible for direct bank transfer subsidy up to ₹78,000 for your 3kW installation.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.primaryFixedDim,
                        fontSize: 12,
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

  Widget _buildNeighborhoodImpact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Neighborhood Impact',
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Indiranagar Ward 74',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Row(
          children: [
            const Expanded(
              child: AppMetricCard(
                icon: Icons.forest,
                iconColor: AppColors.secondary,
                tag: 'Lifetime',
                value: '142',
                caption: 'Trees planted offset',
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: AppMetricCard(
                icon: Icons.savings,
                iconColor: AppColors.onTertiaryContainer,
                tag: '25 Year Net',
                value: '₹9.8 L',
                valueColor: AppColors.primary,
                caption: 'Projected total gain',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWarrantyCard(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () => _showWarrantyModal(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 18,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '25-Year Manufacturer Warranty included',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
