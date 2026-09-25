import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/rooftop_analysis_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_badge.dart';

/// AI Roof Analysis Screen (Stitch: 46721b493c494c3891ffe96a391ab0b2)
/// Simulates LiDAR terrace scanning, computer vision segmentation, and multi-step pipeline progression.
class AiRoofAnalysisScreen extends StatefulWidget {
  final RooftopAnalysisService? analysisService;

  const AiRoofAnalysisScreen({super.key, this.analysisService});

  @override
  State<AiRoofAnalysisScreen> createState() => _AiRoofAnalysisScreenState();
}

class _AiRoofAnalysisScreenState extends State<AiRoofAnalysisScreen>
    with TickerProviderStateMixin {
  late final RooftopAnalysisService _service;
  late final StreamSubscription<AnalysisProgressState> _subscription;
  late AnalysisProgressState _state;

  // Scanner sweep animation
  late final AnimationController _scannerController;
  late final Animation<double> _scannerPosition;

  // Real-time capacity counter fluctuation animation
  late final AnimationController _counterPulseController;
  final List<String> _simulatedKwpValues = [
    '5.6 kWp',
    '5.8 kWp',
    '6.1 kWp',
    '5.8 kWp',
  ];
  int _counterIndex = 0;
  Timer? _counterTimer;

  @override
  void initState() {
    super.initState();
    _service = widget.analysisService ?? MockRooftopAnalysisService();
    _state = _service.currentState;

    // Laser sweep line up and down between 20% and 78% height
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scannerPosition = Tween<double>(begin: 0.20, end: 0.78).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    // Subtle counter fluctuation to simulate real-time ML computation
    _counterPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _counterTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted) return;
      if (_state.phase == AnalysisPhase.solarPotentialCalculated ||
          _state.phase == AnalysisPhase.analysing) {
        setState(() {
          _counterIndex = (_counterIndex + 1) % _simulatedKwpValues.length;
        });
      }
    });

    _subscription = _service.progressStream.listen((newState) {
      if (!mounted) return;
      setState(() {
        _state = newState;
        if (_state.isComplete) {
          _counterTimer?.cancel();
          _counterTimer = null;
          _scannerController.stop();
        }
      });
    });

    // Start deterministic analysis
    _service.startAnalysis();
  }

  @override
  void dispose() {
    _counterTimer?.cancel();
    _counterPulseController.dispose();
    _scannerController.dispose();
    _subscription.cancel();
    // Only dispose if created locally
    if (widget.analysisService == null) {
      _service.dispose();
    }
    super.dispose();
  }

  void _handleNavigateToResult() {
    Navigator.pushNamed(context, AppRoutes.roofResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Progress Header Meta Bar
            _buildProgressHeader(),

            // Scrollable Content Pipeline
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.spaceXs),

                    // 2. Hero Section: Aerial Rooftop Computer Vision Scan View
                    _buildHeroScannerSection(),

                    const SizedBox(height: AppSpacing.spaceMd),

                    // 3. Primary Status Headline & Microcopy
                    _buildStatusHeadline(),

                    const SizedBox(height: AppSpacing.spaceSm),

                    // 4. Overall Progress Bar
                    _buildOverallProgressBar(),

                    const SizedBox(height: AppSpacing.spaceSm),

                    // 5. Multi-Step Pipeline Card
                    _buildPipelineCard(),

                    const SizedBox(height: AppSpacing.spaceSm),

                    // 6. PM Surya Ghar Subsidy Reassurance Banner
                    _buildSubsidyBanner(),

                    const SizedBox(height: AppSpacing.spaceMd),

                    // 7. Action CTA Button
                    _buildBottomActionCta(),

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
              // Back Button
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

              // Step Capsule
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                    const PulsingDot(size: 7, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'Step 3 of 5',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· AI Analysis',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Right Controls: 0.3m Res & Fast-Forward
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadii.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.satellite_alt,
                      size: 15,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '0.3m Res',
                      style: AppTypography.labelMd.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!_state.isComplete) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _service.fastForward(),
                  borderRadius: AppRadii.full,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed.withValues(alpha: 0.5),
                      borderRadius: AppRadii.full,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fast_forward,
                          size: 14,
                          color: AppColors.tertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Skip',
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
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroScannerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const height = 310.0;

          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14164A38),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Terrace Aerial Satellite Representation
                  CustomPaint(
                    size: Size(width, height),
                    painter: _VisionTerracePainter(),
                  ),

                  // 2. Ambient Solar Irradiance Gradient Tint
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.65),
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.35),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // 3. Identified Usable Terrace Polygon Mesh & Overlays
                  CustomPaint(
                    size: Size(width, height),
                    painter: _VisionMeshPainter(
                      progress: _state.progress,
                      isObstacleIsolated: _state.progress >= 0.55,
                      showPanels: _state.progress >= 0.75,
                    ),
                  ),

                  // 4. Animated Laser Scanner Sweep Line
                  AnimatedBuilder(
                    animation: _scannerPosition,
                    builder: (context, child) {
                      return Positioned(
                        top: height * _scannerPosition.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.secondaryFixed,
                                AppColors.secondaryFixedDim,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.3, 0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9EF6AD)
                                    .withValues(alpha: 0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // 5. Water Tank Obstacle Shadow Tag
                  Positioned(
                    top: height * 0.28,
                    right: 28,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x66BA1A1A),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer.withValues(
                              alpha: 0.95,
                            ),
                            borderRadius: AppRadii.full,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            'Shadow Zone (Sintex)',
                            style: AppTypography.labelMd.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 6. Floating Live Reticle Active Pill (Top Left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.85),
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
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryFixed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _state.isComplete
                                ? 'LiDAR Mesh Locked'
                                : 'Target Reticle Active',
                            style: AppTypography.labelMd.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 7. Bottom 3-Column HUD Metric Tiles Overlay
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      children: [
                        // Irradiance
                        Expanded(
                          child: _buildHudTile(
                            label: 'Irradiance',
                            value: '5.4',
                            unit: 'kWh/m²',
                            valueColor: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Roof Slope
                        Expanded(
                          child: _buildHudTile(
                            label: 'Roof Slope',
                            value: 'Flat (0°)',
                            unit: 'RCC Slab',
                            valueColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Azimuth
                        Expanded(
                          child: _buildHudTile(
                            label: 'Azimuth',
                            value: '180° South',
                            unit: 'Optimal Sun',
                            valueColor: AppColors.tertiary,
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

  Widget _buildHudTile({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelMd.copyWith(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.labelLg.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            unit,
            style: AppTypography.bodyMd.copyWith(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeadline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _state.statusTitle,
              key: ValueKey(_state.statusTitle),
              textAlign: TextAlign.center,
              style: AppTypography.headlineMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _state.statusDescription,
              key: ValueKey(_state.statusDescription),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Vision Pipeline Progress',
                style: AppTypography.labelMd.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '${(_state.progress * 100).toInt()}%',
                style: AppTypography.labelMd.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppRadii.full,
            child: LinearProgressIndicator(
              value: _state.progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineCard() {
    final isStep1Complete = _state.progress >= 0.55;
    final isStep1Active = _state.progress >= 0.20 && !isStep1Complete;

    final isStep2Complete = _state.progress >= 0.75;
    final isStep2Active = isStep1Complete && !isStep2Complete;

    final isStep3Complete = _state.progress >= 1.0;
    final isStep3Active = isStep2Complete && !isStep3Complete;

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
          children: [
            // Pipeline Step 1: Boundary & Parapet
            _buildPipelineStepRow(
              isCompleted: isStep1Complete,
              isActive: isStep1Active,
              title: 'Boundary & Parapet Detected',
              metricBadge: '1,480 sq.ft',
              subtitle: 'Reinforced parapet buffers calibrated.',
              metricColor: AppColors.secondary,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: AppColors.surfaceContainerHigh),
            ),

            // Pipeline Step 2: Shadow Obstacles Isolated
            _buildPipelineStepRow(
              isCompleted: isStep2Complete,
              isActive: isStep2Active,
              title: 'Shadow Obstacles Isolated',
              metricBadge: '2 Excluded',
              subtitle: 'Mumty tower and Sintex water storage mapped.',
              metricColor: AppColors.secondary,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: AppColors.surfaceContainerHigh),
            ),

            // Pipeline Step 3: Optimal Panel Count
            _buildPipelineStepRow(
              isCompleted: isStep3Complete,
              isActive: isStep3Active,
              title: 'Calculating Optimal Panel Count',
              metricBadge: isStep3Complete
                  ? '5.8 kWp'
                  : _simulatedKwpValues[_counterIndex],
              subtitle: 'Arranging 14 bifacial mono-PERC modules.',
              metricColor: isStep3Complete
                  ? AppColors.secondary
                  : AppColors.tertiary,
              isHighlightActive: isStep3Active,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineStepRow({
    required bool isCompleted,
    required bool isActive,
    required String title,
    required String metricBadge,
    required String subtitle,
    required Color metricColor,
    bool isHighlightActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Icon indicator
        _buildStepIndicator(isCompleted: isCompleted, isActive: isActive),
        const SizedBox(width: 12),

        // Text Content
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppColors.primary
                            : (isCompleted
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.secondaryContainer.withValues(alpha: 0.6)
                          : (isActive
                                ? AppColors.tertiaryFixed.withValues(alpha: 0.5)
                                : AppColors.surfaceContainer),
                      borderRadius: AppRadii.full,
                    ),
                    child: Text(
                      metricBadge,
                      style: AppTypography.labelMd.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: metricColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
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

  Widget _buildStepIndicator({
    required bool isCompleted,
    required bool isActive,
  }) {
    if (isCompleted) {
      return Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: AppColors.secondaryContainer,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: AppColors.onSecondaryContainer,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.tertiaryFixed.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.tertiary),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.radio_button_unchecked,
        size: 18,
        color: AppColors.outlineVariant,
      ),
    );
  }

  Widget _buildSubsidyBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceSm,
          vertical: AppSpacing.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondaryContainer, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user,
                size: 18,
                color: AppColors.onSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PM Surya Ghar: Muft Bijli Yojana',
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Central subsidy eligibility up to ₹78,000 verified automatically in real-time.',
                    style: AppTypography.bodyMd.copyWith(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      height: 1.2,
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

  Widget _buildBottomActionCta() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
      child: Column(
        children: [
          if (_state.isComplete)
            AppButton(
              label: 'View Solar Assessment Results',
              showTrailingArrowBadge: true,
              onPressed: _handleNavigateToResult,
            )
          else
            AppButton(
              label: _state.phase == AnalysisPhase.solarPotentialCalculated
                  ? 'Finalizing Solar Layout...'
                  : 'Analyzing Rooftop (${(_state.progress * 100).toInt()}%)...',
              isLoading: true,
              onPressed: null,
            ),
          const SizedBox(height: 8),
          Text(
            'Analysis takes ~4 seconds · High precision LiDAR mesh',
            textAlign: TextAlign.center,
            style: AppTypography.labelMd.copyWith(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Photorealistic simulation of Bangalore residential terrace for offline & widget tests.
class _VisionTerracePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Aerial city ground
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF2C3531),
    );

    // Green tree canopies around building
    final treePaint = Paint()..color = const Color(0xFF1E3827);
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.15),
      45,
      treePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.85),
      55,
      treePaint,
    );

    // Main terrace concrete surface
    final roofRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.48),
      width: size.width * 0.82,
      height: size.height * 0.68,
    );

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        roofRect.translate(4, 8),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0x33000000),
    );

    // Concrete slab
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFC8BCA8),
    );

    // Parapet coping border
    final parapetPaint = Paint()
      ..color = const Color(0xFFB5A792)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(8)),
      parapetPaint,
    );

    // Mumty tower / stair room
    final mumtyRect = Rect.fromLTWH(
      roofRect.left + roofRect.width * 0.58,
      roofRect.top + roofRect.height * 0.18,
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

    // Black overhead sintex tank
    canvas.drawCircle(
      Offset(
        mumtyRect.left + mumtyRect.width * 0.5,
        mumtyRect.top + mumtyRect.height * 0.5,
      ),
      14,
      Paint()..color = const Color(0xFF1E2D2F),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Computer vision mesh overlay painter representing usable boundary, panel grid, and shadow zones.
class _VisionMeshPainter extends CustomPainter {
  final double progress;
  final bool isObstacleIsolated;
  final bool showPanels;

  _VisionMeshPainter({
    required this.progress,
    required this.isObstacleIsolated,
    required this.showPanels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final usablePath = Path();
    usablePath.moveTo(size.width * 0.16, size.height * 0.22);
    usablePath.lineTo(size.width * 0.84, size.height * 0.19);
    usablePath.lineTo(size.width * 0.88, size.height * 0.77);
    usablePath.lineTo(size.width * 0.12, size.height * 0.80);
    usablePath.close();

    // 1. Usable terrace polygon mesh fill
    final meshPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF9EF6AD).withValues(alpha: 0.38),
          const Color(0xFF366854).withValues(alpha: 0.15),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(usablePath, meshPaint);

    // Green stroke outline
    final strokePaint = Paint()
      ..color = const Color(0xFF9EF6AD)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(usablePath, strokePaint);

    // 2. Projected solar panels pattern (if stage reached)
    if (showPanels) {
      canvas.save();
      canvas.clipPath(usablePath);

      final panelPaint = Paint()
        ..color = const Color(0xFF164A38).withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;
      final panelBorderPaint = Paint()
        ..color = const Color(0xFF9EF6AD).withValues(alpha: 0.9)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      // Draw rows of monocrystalline modules in clear sunny patch
      const panelWidth = 24.0;
      const panelHeight = 36.0;
      final startX = size.width * 0.20;
      final startY = size.height * 0.30;

      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 4; col++) {
          final pRect = Rect.fromLTWH(
            startX + (col * (panelWidth + 4)),
            startY + (row * (panelHeight + 4)),
            panelWidth,
            panelHeight,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(pRect, const Radius.circular(2)),
            panelPaint,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(pRect, const Radius.circular(2)),
            panelBorderPaint,
          );
        }
      }
      canvas.restore();
    }

    // 3. Obstacle Bounding Box: Water Tank & Mumty Zone
    if (isObstacleIsolated) {
      final tankRect = Rect.fromLTWH(
        size.width * 0.58,
        size.height * 0.26,
        size.width * 0.25,
        size.height * 0.24,
      );

      final tankFill = Paint()
        ..color = const Color(0xFFBA1A1A).withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(tankRect, const Radius.circular(6)),
        tankFill,
      );

      final tankStroke = Paint()
        ..color = const Color(0xFFBA1A1A)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(tankRect, const Radius.circular(6)),
        tankStroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VisionMeshPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isObstacleIsolated != isObstacleIsolated ||
        oldDelegate.showPanels != showPanels;
  }
}
