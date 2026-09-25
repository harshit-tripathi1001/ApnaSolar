import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/app_button.dart';

/// Roof Result Screen (Stitch: 3dbdce19abb641e586edd16c24173636)
/// Presents AI verified usable area (1,120 sq ft), 5.8 kWp capacity, 12 modules, and PM Surya Ghar subsidy.
class RoofResultScreen extends StatelessWidget {
  final double usableAreaSqFt;
  final double totalAreaSqFt;
  final double capacityKw;
  final int panelCount;
  final double monthlySavings;
  final int treeOffset;

  const RoofResultScreen({
    super.key,
    this.usableAreaSqFt = 1120.0,
    this.totalAreaSqFt = 1440.0,
    this.capacityKw = 5.8,
    this.panelCount = 12,
    this.monthlySavings = 4250.0,
    this.treeOffset = 182,
  });

  String _formatNumber(num number) {
    return number.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Progress Header Bar
            _buildProgressHeader(context),

            // Scrollable Assessment Results
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.spaceXs),

                    // 2. Hero Visual: Indian Terrace with AR Overlays
                    _buildHeroVisual(context),

                    const SizedBox(height: AppSpacing.spaceMd),

                    // 3. Primary Metric Hero Section
                    _buildPrimaryMetricSection(),

                    const SizedBox(height: AppSpacing.spaceSm),

                    // 4. System & Financial Snapshot Card
                    _buildSystemSnapshotCard(),

                    const SizedBox(height: AppSpacing.spaceSm),

                    // 5. Estimated Impact Micro-Grid (Monthly Offset & Carbon Value)
                    _buildImpactGrid(),

                    const SizedBox(height: AppSpacing.spaceMd),

                    // 6. Action CTAs
                    _buildActionButtons(context),

                    const SizedBox(height: AppSpacing.spaceLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: AppRadii.full,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Step 3 of 5',
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '•',
                    style: TextStyle(color: AppColors.outlineVariant),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Roof Assessment',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: AppRadii.full,
                ),
                child: Text(
                  'AI Verified',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondaryContainer,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 5-Step Segmented Bar (3 complete)
          Row(
            children: [
              Expanded(child: _stepSegment(isFilled: true)),
              const SizedBox(width: 4),
              Expanded(child: _stepSegment(isFilled: true)),
              const SizedBox(width: 4),
              Expanded(child: _stepSegment(isFilled: true)),
              const SizedBox(width: 4),
              Expanded(child: _stepSegment(isFilled: false)),
              const SizedBox(width: 4),
              Expanded(child: _stepSegment(isFilled: false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepSegment({required bool isFilled}) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: isFilled
            ? AppColors.secondary
            : AppColors.surfaceContainerHighest,
        borderRadius: AppRadii.full,
      ),
    );
  }

  Widget _buildHeroVisual(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const height = 250.0;

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14164A38),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Base Photorealistic Terrace Painter
                  CustomPaint(
                    size: Size(width, height),
                    painter: _ResultTerracePainter(),
                  ),

                  // Ambient Gradient Vignette
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.55),
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.35),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Computer Vision Overlays: Amber Shadow Buffer & Green Usable Area & 12 Solar Modules
                  CustomPaint(
                    size: Size(width, height),
                    painter: _ResultOverlayPainter(),
                  ),

                  // Top Left: Map Legend Floating Pill
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest.withValues(
                          alpha: 0.92,
                        ),
                        borderRadius: AppRadii.full,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
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
                          const SizedBox(width: 4),
                          Text(
                            'Sunny Patch',
                            style: AppTypography.labelMd.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '•',
                            style: TextStyle(
                              color: AppColors.outlineVariant,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0C03E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Shadow Buffer',
                            style: AppTypography.labelMd.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top Right: Sun Orientation Live Badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadii.full,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sunny,
                            size: 13,
                            color: AppColors.tertiaryFixed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'South-Facing',
                            style: AppTypography.labelMd.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Floating Terrace Details & Fine-Tune CTA
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest.withValues(
                          alpha: 0.95,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
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
                                child: const Icon(
                                  Icons.satellite_alt,
                                  size: 16,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Plot #42, Indiranagar',
                                    style: AppTypography.labelMd.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'High Accuracy Satellite Scan',
                                    style: AppTypography.bodyMd.copyWith(
                                      fontSize: 10,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.satelliteRoofDrawing,
                            ),
                            borderRadius: AppRadii.full,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: AppRadii.full,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.tune,
                                    size: 13,
                                    color: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Fine-Tune',
                                    style: AppTypography.labelMd.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrimaryMetricSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C164A38),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'USABLE SOLAR TERRACE AREA',
                  style: AppTypography.labelMd.copyWith(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: AppRadii.full,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wb_twilight,
                        size: 14,
                        color: AppColors.onSecondaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '78% shadow-free',
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Huge Metric Value
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatNumber(usableAreaSqFt),
                  style: AppTypography.statCounter.copyWith(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'sq. ft',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Out of ${_formatNumber(totalAreaSqFt)} sq.ft total roof area. The rest is safely buffered for water overheads and clear terrace access.',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),

            // Visual Solar Capacity Highlight Block
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.tertiaryFixed.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixedDim.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      size: 22,
                      color: AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${capacityKw.toStringAsFixed(1)} kW Peak Capacity',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Generates ~22 clean units (kWh) / day',
                          style: AppTypography.bodyMd.copyWith(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.trending_up,
                    size: 24,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSnapshotCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C164A38),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.solar_power,
                    size: 20,
                    color: AppColors.secondaryFixed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fits $panelCount Monocrystalline Panels',
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tier-1 bi-facial modules with 25-year 85% generation guarantee.',
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Subsidy Notification Banner
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurface,
                        ),
                        children: const [
                          TextSpan(text: 'PM Surya Ghar Muft Bijli: '),
                          TextSpan(
                            text: 'Eligible for max ₹78,000 direct subsidy',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
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
    );
  }

  Widget _buildImpactGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Row(
        children: [
          // Rupee Monthly Savings
          Expanded(
            child: _impactCard(
              icon: Icons.currency_rupee,
              label: 'Monthly Offset',
              value: '₹${_formatNumber(monthlySavings)}',
              subtext: '92% bill reduction',
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),

          // Eco Impact Metric
          Expanded(
            child: _impactCard(
              icon: Icons.park,
              label: 'Carbon Value',
              value: '$treeOffset Trees',
              subtext: 'CO2 offset / year',
            ),
          ),
        ],
      ),
    );
  }

  Widget _impactCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C164A38),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.secondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: AppTypography.labelMd.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        children: [
          // Primary CTA Button
          AppButton(
            label: 'See My Solar Plan',
            showTrailingArrowBadge: true,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.solarRecommendation);
            },
          ),
          const SizedBox(height: 6),

          // Secondary CTA: Adjust Roof Boundary Manually
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.satelliteRoofDrawing);
            },
            borderRadius: AppRadii.full,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.edit_road,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Adjust Roof Boundary Manually',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photorealistic simulation of Bangalore residential terrace for Roof Result screen.
class _ResultTerracePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // City ground
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF2C3531),
    );

    // Green tree foliage
    final treePaint = Paint()..color = const Color(0xFF1E3827);
    canvas.drawCircle(
      Offset(size.width * 0.05, size.height * 0.15),
      45,
      treePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.85),
      50,
      treePaint,
    );

    // Main terrace slab
    final roofRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.48),
      width: size.width * 0.82,
      height: size.height * 0.68,
    );

    // Concrete drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        roofRect.translate(4, 6),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0x33000000),
    );

    // Concrete slab surface
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFC8BCA8),
    );

    // Terrace parapet
    final parapetPaint = Paint()
      ..color = const Color(0xFFB5A792)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(8)),
      parapetPaint,
    );

    // Mumty stair tower
    final mumtyRect = Rect.fromLTWH(
      roofRect.left + roofRect.width * 0.08,
      roofRect.top + roofRect.height * 0.14,
      roofRect.width * 0.28,
      roofRect.height * 0.30,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        mumtyRect.translate(2, 3),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0x2A000000),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mumtyRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFDFD7CA),
    );

    // Sintex water tank
    canvas.drawCircle(
      Offset(
        mumtyRect.left + mumtyRect.width * 0.5,
        mumtyRect.top + mumtyRect.height * 0.5,
      ),
      13,
      Paint()..color = const Color(0xFF1E2D2F),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Overlay painter for Roof Result: Amber shadow buffer, green sunny zone, and 12 monocrystalline PV panels.
class _ResultOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Amber Shadow Buffer Zone (Mumty & water tank area)
    final shadowPath = Path();
    shadowPath.moveTo(size.width * 0.14, size.height * 0.20);
    shadowPath.lineTo(size.width * 0.38, size.height * 0.16);
    shadowPath.lineTo(size.width * 0.42, size.height * 0.48);
    shadowPath.lineTo(size.width * 0.18, size.height * 0.52);
    shadowPath.close();

    final amberFill = Paint()
      ..color = const Color(0xFFF0C03E).withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, amberFill);

    final amberStroke = Paint()
      ..color = const Color(0xFFF0C03E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(shadowPath, amberStroke);

    // 2. Green Usable Roof Polygon
    final sunnyPath = Path();
    sunnyPath.moveTo(size.width * 0.40, size.height * 0.20);
    sunnyPath.lineTo(size.width * 0.86, size.height * 0.22);
    sunnyPath.lineTo(size.width * 0.82, size.height * 0.74);
    sunnyPath.lineTo(size.width * 0.32, size.height * 0.70);
    sunnyPath.close();

    final greenFill = Paint()
      ..color = const Color(0xFF9EF6AD).withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    canvas.drawPath(sunnyPath, greenFill);

    final greenStroke = Paint()
      ..color = const Color(0xFF0B6D33)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(sunnyPath, greenStroke);

    // 3. Rendered 12 Solar Modules neatly placed in 2 rows of 6
    final panelFill = Paint()
      ..color = const Color(0xFF164A38).withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;
    final panelBorder = Paint()
      ..color = const Color(0xFFB9EED5)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    const pWidth = 18.0;
    const pHeight = 28.0;
    final startX = size.width * 0.43;
    final startY1 = size.height * 0.28;
    final startY2 = size.height * 0.44;

    for (int col = 0; col < 6; col++) {
      // Row 1
      final r1 = Rect.fromLTWH(
        startX + (col * (pWidth + 3)),
        startY1,
        pWidth,
        pHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r1, const Radius.circular(2)),
        panelFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r1, const Radius.circular(2)),
        panelBorder,
      );

      // Row 2
      final r2 = Rect.fromLTWH(
        startX + (col * (pWidth + 3)),
        startY2,
        pWidth,
        pHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r2, const Radius.circular(2)),
        panelFill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r2, const Radius.circular(2)),
        panelBorder,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
