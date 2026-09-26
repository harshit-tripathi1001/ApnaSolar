import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/financial_breakdown.dart';
import '../../models/solar_estimate.dart';
import '../../services/solar_calculator_service.dart';
import '../../services/solar_session_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_badge.dart';

/// Solar Recommendation Screen (Stitch: 904784247fc147f8a1a540e7e943ab7d)
/// Primary solar results experience communicating capacity, savings, payback, and environmental impact.
class SolarRecommendationScreen extends StatefulWidget {
  final double initialCapacityKw;
  final double usableAreaSqFt;
  final double totalRoofAreaSqFt;
  final double currentMonthlyBill;

  const SolarRecommendationScreen({
    super.key,
    this.initialCapacityKw = 5.8,
    this.usableAreaSqFt = 1120.0,
    this.totalRoofAreaSqFt = 1440.0,
    this.currentMonthlyBill = 3850.0,
  });

  @override
  State<SolarRecommendationScreen> createState() =>
      _SolarRecommendationScreenState();
}

class _SolarRecommendationScreenState extends State<SolarRecommendationScreen>
    with SingleTickerProviderStateMixin {
  late double _selectedCapacityKw;
  late SolarEstimate _solarEstimate;
  late FinancialBreakdown _financials;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _countUpAnimation;
  late final Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    final session = SolarSessionState();
    final effectiveCapacity = widget.initialCapacityKw != 5.8
        ? widget.initialCapacityKw
        : session.selectedCapacityKw;
    _selectedCapacityKw = effectiveCapacity;
    _recalculate();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _countUpAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
    );

    _chartAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final session = SolarSessionState();
    _solarEstimate = SolarCalculatorService.calculateEstimate(
      capacityKw: _selectedCapacityKw,
      peakSunHours: session.selectedProperty.peakSunHoursPerDay,
    );
    final effectiveBill = widget.currentMonthlyBill != 3850.0
        ? widget.currentMonthlyBill
        : session.monthlyBill;
    _financials = SolarCalculatorService.calculateFinancials(
      capacityKw: _selectedCapacityKw,
      currentMonthlyBill: effectiveBill,
    );
    if (session.selectedCapacityKw != _selectedCapacityKw) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        session.setSelectedCapacity(_selectedCapacityKw);
      });
    }
  }

  String _formatCurrency(num value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _openCustomizerModal() {
    double tempCapacity = _selectedCapacityKw.clamp(3.5, 7.5);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final modalFinancials = SolarCalculatorService.calculateFinancials(
              capacityKw: tempCapacity,
              currentMonthlyBill: widget.currentMonthlyBill,
            );

            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26164A38),
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.margin,
                AppSpacing.spaceMd,
                AppSpacing.margin,
                MediaQuery.of(context).viewInsets.bottom + AppSpacing.spaceLg,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: AppRadii.full,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Adjust System Size',
                                style: AppTypography.headlineSm.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(modalContext),
                            icon: const Icon(Icons.close, size: 20),
                            color: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Preview how varying rooftop solar capacities impact your monthly savings and roof coverage.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spaceMd),

                      // Selected size callout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Capacity',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: AppRadii.full,
                            ),
                            child: Text(
                              '${tempCapacity.toStringAsFixed(1)} kW',
                              style: AppTypography.headlineSm.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceContainerHighest,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: tempCapacity,
                          min: 3.5,
                          max: 7.5,
                          divisions: 8,
                          onChanged: (val) {
                            setModalState(() {
                              tempCapacity = (val * 2).round() / 2.0;
                            });
                          },
                        ),
                      ),

                      // Range labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '3.5 kW (Budget)',
                              style: AppTypography.labelMd.copyWith(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '5.8 kW (Optimal)',
                              style: AppTypography.labelMd.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '7.5 kW (Max Generation)',
                              style: AppTypography.labelMd.copyWith(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spaceMd),

                      // Impact Preview Bento in Modal
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.spaceSm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Projected Monthly Savings',
                                  style: AppTypography.labelMd.copyWith(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${_formatCurrency(modalFinancials.monthlySavings)} / mo',
                                  style: AppTypography.headlineSm.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            AppButton(
                              label: 'Apply Size',
                              width: 120,
                              height: 44,
                              onPressed: () {
                                setState(() {
                                  _selectedCapacityKw = tempCapacity;
                                  _recalculate();
                                });
                                Navigator.pop(modalContext);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Navigation Header & Progress Context
            _buildProgressHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.spaceXs),

                      // 2. Hero Header
                      _buildHeroHeader(),

                      // 3. Hero Visual Card: 3D Rooftop Representation
                      _buildHeroVisualCard(),

                      const SizedBox(height: AppSpacing.spaceMd),

                      // 4. PRIMARY SOLAR RESULT: Giant Impact Stat Block
                      _buildGiantImpactBlock(),

                      const SizedBox(height: AppSpacing.spaceMd),

                      // 5. Monthly Solar Generation vs Consumption Chart
                      _buildGenerationChartSection(),

                      const SizedBox(height: AppSpacing.spaceMd),

                      // 6. Comprehensive Solar System Specs & Financial Hierarchy
                      _buildSystemSpecsBento(),

                      const SizedBox(height: AppSpacing.spaceMd),

                      // 7. Key Plan Highlights
                      _buildPlanHighlights(),

                      const SizedBox(height: AppSpacing.spaceMd),

                      // 8. Environmental Delight Micro-Card
                      _buildEnvironmentalCard(),

                      const SizedBox(height: AppSpacing.spaceLg),

                      // 9. Action CTAs
                      _buildActionButtons(),

                      const SizedBox(height: AppSpacing.spaceXl),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.roofResult);
                  }
                },
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest.withValues(
                    alpha: 0.8,
                  ),
                  borderRadius: AppRadii.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulsingDot(size: 6, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'Step 4 of 5',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // AI Optimized Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
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
                const Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.onSecondaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'AI Optimized',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondaryContainer,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tertiaryFixed,
              borderRadius: AppRadii.full,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wb_sunny,
                  size: 14,
                  color: AppColors.onTertiaryFixed,
                ),
                const SizedBox(width: 4),
                Text(
                  '98.4% Solar Insolation Match',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onTertiaryFixed,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Perfect Solar Match',
            style: AppTypography.headlineLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Engineered for your '),
                TextSpan(
                  text: 'Indiranagar home',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const TextSpan(text: ' based on your '),
                TextSpan(
                  text: '420 units/mo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' BESCOM baseline.'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
        ],
      ),
    );
  }

  Widget _buildHeroVisualCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const height = 240.0;

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F164A38),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photorealistic Bangalore Villa 3D Rooftop Painter
                  CustomPaint(
                    size: Size(width, height),
                    painter: _Solar3DRooftopPainter(),
                  ),

                  // Ambient Solar Gold & Dark Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.65),
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.90),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Top Left: Capacity Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(
                          alpha: 0.95,
                        ),
                        borderRadius: AppRadii.full,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 15,
                            color: AppColors.onSecondaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_selectedCapacityKw.toStringAsFixed(1)} kW System Capacity',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryContainer,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top Right: Sun-Path Badge
                  Positioned(
                    top: 10,
                    right: 10,
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
                          const Icon(
                            Icons.sunny,
                            size: 14,
                            color: Color(0xFFF0C03E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Bangalore Sun-Path: 5.2 hrs/day',
                            style: AppTypography.labelMd.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Specs Floating Bento
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: [
                        // Panels
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest
                                  .withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.solar_power,
                                    size: 16,
                                    color: AppColors.onSecondaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_solarEstimate.panelCount} Bi-Facial Panels',
                                        style: AppTypography.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'TopCon 550W Tier-1',
                                        style: AppTypography.bodyMd.copyWith(
                                          fontSize: 10,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Daily Units
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest
                                  .withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiaryFixed.withValues(
                                      alpha: 0.7,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.electric_meter,
                                    size: 16,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '~${_solarEstimate.dailyGenerationKwh.toStringAsFixed(0)} Units / Day',
                                        style: AppTypography.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                          fontSize: 11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${_solarEstimate.monthlyGenerationKwh.toStringAsFixed(0)} Units Monthly',
                                        style: AppTypography.bodyMd.copyWith(
                                          fontSize: 10,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
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
        },
      ),
    );
  }

  Widget _buildGiantImpactBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceLg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F164A38),
              blurRadius: 18,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Pre-header Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.trending_down,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'ESTIMATED ELECTRICITY DROP',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Giant Currency Value with Animated Count-Up
            AnimatedBuilder(
              animation: _countUpAnimation,
              builder: (context, child) {
                final animatedVal =
                    (_financials.monthlySavings * _countUpAnimation.value)
                        .round();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${_formatCurrency(animatedVal)}',
                      style: AppTypography.statCounter.copyWith(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ mo saved',
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Before / After Bill Comparison Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Today's Bill
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S BILL",
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '₹${_formatCurrency(widget.currentMonthlyBill)}',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.error,
                          decorationThickness: 2,
                        ),
                      ),
                    ],
                  ),

                  // Percentage Cut Badge
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
                          Icons.arrow_forward,
                          size: 13,
                          color: AppColors.onSecondaryContainer,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '87% Cut',
                          style: AppTypography.labelMd.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // With ApnaSolar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'WITH APNASOLAR',
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '₹${_formatCurrency(_financials.projectedMonthlyBill)}',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Annual Savings Badge Callout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed.withValues(alpha: 0.5),
                borderRadius: AppRadii.full,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.savings,
                    size: 17,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '₹${_formatCurrency(_financials.annualSavings)}/year back in your bank account',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryFixed,
                        fontSize: 11,
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

  Widget _buildGenerationChartSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C164A38),
              blurRadius: 10,
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
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bar_chart,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Annual Generation Curve',
                          style: AppTypography.labelLg.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppRadii.full,
                  ),
                  child: Text(
                    '8,640 kWh/yr',
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Bangalore seasonal insolation vs your 420 kWh monthly consumption baseline.',
              style: AppTypography.bodyMd.copyWith(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),

            // Animated Bar Chart
            AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SolarGenerationCurvePainter(
                      progress: _chartAnimation.value,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // Chart Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _chartLegendItem(
                  color: AppColors.secondary,
                  label: 'Solar Generated',
                ),
                const SizedBox(width: 14),
                _chartLegendItem(
                  color: AppColors.error.withValues(alpha: 0.6),
                  label: 'Baseline Use (420)',
                  isDashed: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: isDashed ? 3 : 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            fontSize: 10,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemSpecsBento() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solar & Financial Metrics',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 2x2 Bento Grid
          Row(
            children: [
              // 1. Usable Rooftop Area
              Expanded(
                child: _metricTile(
                  icon: Icons.roofing,
                  label: 'Usable Rooftop Area',
                  value: '${_formatCurrency(widget.usableAreaSqFt)} sq. ft',
                  subtext: '78% shadow-free terrace',
                  accentColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),

              // 2. Turnkey Net Cost
              Expanded(
                child: _metricTile(
                  icon: Icons.payments,
                  label: 'Net Turnkey Cost',
                  value: '₹${_formatCurrency(_financials.netPayableCost)}',
                  subtext: '₹78k subsidy applied',
                  accentColor: AppColors.secondary,
                  isHighlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          Row(
            children: [
              // 3. Payback Period
              Expanded(
                child: _metricTile(
                  icon: Icons.timer,
                  label: 'Payback Period',
                  value:
                      '${_financials.paybackPeriodYears.toStringAsFixed(1)} Years',
                  subtext: 'ROI in 38 months',
                  accentColor: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),

              // 4. Lifetime Gain (25 Yr)
              Expanded(
                child: _metricTile(
                  icon: Icons.account_balance_wallet,
                  label: '25-Yr Net Savings',
                  value:
                      '₹${(_financials.cumulative25YearSavings / 100000).toStringAsFixed(2)} L',
                  subtext: 'Cumulative 25-yr gain',
                  accentColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Payback Timeline Visual Progress Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C164A38),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Payback vs 25-Year System Lifetime',
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(25 - _financials.paybackPeriodYears).toStringAsFixed(1)} Yrs Free Power',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Dual-segmented visual timeline bar
                ClipRRect(
                  borderRadius: AppRadii.full,
                  child: Row(
                    children: [
                      // Payback segment
                      Flexible(
                        flex: (_financials.paybackPeriodYears * 10).round(),
                        child: Container(
                          height: 10,
                          color: const Color(0xFFF0C03E),
                        ),
                      ),
                      // Pure profit segment
                      Flexible(
                        flex: ((25 - _financials.paybackPeriodYears) * 10)
                            .round(),
                        child: Container(
                          height: 10,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Year 0',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 9,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Break-even (${_financials.paybackPeriodYears.toStringAsFixed(1)}y)',
                      style: AppTypography.labelMd.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A6500),
                      ),
                    ),
                    Text(
                      'Year 25 (84.8% Guarantee)',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 9,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
    required Color accentColor,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.secondaryContainer.withValues(alpha: 0.35)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C164A38),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelMd.copyWith(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtext,
            style: AppTypography.bodyMd.copyWith(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHighlights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Key Plan Highlights',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.verified,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Pre-Verified',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Highlight 1: 100% Day Load Covered
          _highlightCard(
            icon: Icons.power,
            iconBg: AppColors.secondaryContainer,
            iconColor: AppColors.onSecondaryContainer,
            title: '100% Day Load Covered',
            badge: 'Zero Grid Reliance',
            badgeBg: AppColors.secondaryFixed,
            badgeColor: AppColors.onSecondaryFixed,
            body: 'Power 2× 1.5 Ton Inverter ACs, refrigerator, geyser, and EV 2-wheeler charging effortlessly during peak sun hours.',
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Highlight 2: 25-Year Guarantee
          _highlightCard(
            icon: Icons.verified_user,
            iconBg: AppColors.surfaceContainerHigh,
            iconColor: AppColors.primary,
            title: '25-Year Generation Guarantee',
            badge: 'Tier-1 DCR',
            badgeBg: AppColors.surfaceContainerHigh,
            badgeColor: AppColors.onSurfaceVariant,
            body: 'Guaranteed 84.8% performance even at year 25. Includes 10-year hassle-free comprehensive inverter replacement warranty.',
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Highlight 3: PM Surya Ghar Subsidy
          _highlightCard(
            icon: Icons.account_balance,
            iconBg: AppColors.tertiaryFixed,
            iconColor: AppColors.onTertiaryFixed,
            title: '₹78,000 Direct DBT Subsidy',
            badge: 'PM Surya Ghar',
            badgeBg: AppColors.tertiaryFixed,
            badgeColor: AppColors.onTertiaryFixed,
            body: 'Credited directly to your linked Aadhaar bank account within 30 days of bidirectional net-meter installation.',
          ),
        ],
      ),
    );
  }

  Widget _highlightCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A164A38),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: AppRadii.full,
                      ),
                      child: Text(
                        badge,
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: AppTypography.bodyMd.copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F164A38),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.forest,
                    size: 24,
                    color: AppColors.onSecondaryFixed,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lifetime Eco Impact',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.secondaryFixed,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${_solarEstimate.treeOffsetEquivalent} Trees Saved',
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '~${_solarEstimate.co2OffsetTonnesPerYear} Tonnes CO₂ offset per year',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 11,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                size: 22,
                color: AppColors.secondaryFixed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        children: [
          // Primary CTA: View Equipment & Cost Details
          AppButton(
            label: 'View Equipment & Cost Details',
            showTrailingArrowBadge: true,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.costBreakdown);
            },
          ),
          const SizedBox(height: 6),

          // Secondary CTA: Customize system size
          InkWell(
            onTap: _openCustomizerModal,
            borderRadius: AppRadii.full,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tune, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Customize system size (3.5 kW - 7.5 kW)',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Tertiary Quick Nav: View Official Solar Report
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.solarReport);
            },
            borderRadius: AppRadii.full,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View Official Solar Audit Report (PDF)',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      decoration: TextDecoration.underline,
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

/// 3D Bangalore rooftop rendering with mounted monocrystalline panel array and sunbeam.
class _Solar3DRooftopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Aerial terrace environment
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF2C3531),
    );

    // Warm golden hour sunlight flare
    final sunGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, -0.6),
        radius: 1.2,
        colors: [
          const Color(0xFFFFE082).withValues(alpha: 0.55),
          const Color(0xFFFFB74D).withValues(alpha: 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sunGlow);

    // Green foliage around terrace
    final leafPaint = Paint()..color = const Color(0xFF1E3827);
    canvas.drawCircle(
      Offset(size.width * 0.04, size.height * 0.20),
      45,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.96, size.height * 0.85),
      55,
      leafPaint,
    );

    // Terracotta rooftop slab
    final roofRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.50),
      width: size.width * 0.84,
      height: size.height * 0.68,
    );

    // Terrace slab shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        roofRect.translate(4, 6),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0x33000000),
    );

    // Light warm concrete slab
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFC8BCA8),
    );

    // Parapet coping
    final parapetPaint = Paint()
      ..color = const Color(0xFFB5A792)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(8)),
      parapetPaint,
    );

    // Elevated mounting structure & 12 Photovoltaic modules (2 rows of 6)
    final panelFill = Paint()
      ..color = const Color(0xFF0F261E)
      ..style = PaintingStyle.fill;
    final panelBorder = Paint()
      ..color = const Color(0xFF82D993)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const pWidth = 24.0;
    const pHeight = 36.0;
    final startX = size.width * 0.22;
    final startY1 = size.height * 0.30;
    final startY2 = size.height * 0.48;

    for (int col = 0; col < 6; col++) {
      // Row 1
      final r1 = Rect.fromLTWH(
        startX + (col * (pWidth + 4)),
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
        startX + (col * (pWidth + 4)),
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

/// Custom painter for the monthly solar generation curve across 12 months.
class _SolarGenerationCurvePainter extends CustomPainter {
  final double progress;

  _SolarGenerationCurvePainter({required this.progress});

  // Relative monthly generation factors (Jan - Dec) reflecting Bangalore insolation
  static const List<double> _monthGen = [
    0.80,
    0.92,
    1.00,
    0.95,
    0.88,
    0.65,
    0.58,
    0.62,
    0.72,
    0.85,
    0.82,
    0.78,
  ];
  static const List<String> _months = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const bottomLabelHeight = 18.0;
    final chartHeight = size.height - bottomLabelHeight;
    final barWidth = size.width / 14;

    // 1. Draw 420 kWh Baseline consumption line
    final baselineY = chartHeight * 0.45;
    final baselinePaint = Paint()
      ..color = AppColors.error.withValues(alpha: 0.55)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Dashed line
    for (double x = 0; x < size.width; x += 10) {
      canvas.drawLine(
        Offset(x, baselineY),
        Offset(x + 5, baselineY),
        baselinePaint,
      );
    }

    // 2. Draw 12 monthly generation bars
    final barPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.secondaryFixedDim, AppColors.secondary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    final textStyle = AppTypography.labelMd.copyWith(
      fontSize: 9,
      color: AppColors.onSurfaceVariant,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < 12; i++) {
      final x = ((i + 1) * (size.width / 13)) - (barWidth / 2);
      final rawH = chartHeight * _monthGen[i] * 0.95;
      final curH = rawH * progress;
      final y = chartHeight - curH;

      final barRect = Rect.fromLTWH(x, y, barWidth, curH);
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(3)),
        barPaint,
      );

      // Month label below bar
      final textSpan = TextSpan(text: _months[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SolarGenerationCurvePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
