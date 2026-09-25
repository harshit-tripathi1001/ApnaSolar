import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_badge.dart';

/// Satellite Roof Drawing Screen (Stitch: c2f5849a2fce475e852355ebbd623291)
/// Step 2/3 of 5: Allows homeowners to calibrate their rooftop boundary using
/// draggable vertex pins with real-time area calculation and obstacle exclusions.
class SatelliteRoofDrawingScreen extends StatefulWidget {
  const SatelliteRoofDrawingScreen({super.key});

  @override
  State<SatelliteRoofDrawingScreen> createState() =>
      _SatelliteRoofDrawingScreenState();
}

class _SatelliteRoofDrawingScreenState extends State<SatelliteRoofDrawingScreen>
    with SingleTickerProviderStateMixin {
  bool _is3DView = false;
  bool _isAnalyzing = false;
  double _zoomScale = 1.0;

  // Normalized vertex pins (dx, dy in 0.0 - 1.0 range)
  late List<Offset> _vertices;
  late List<Offset> _initialVertices;

  @override
  void initState() {
    super.initState();
    _initialVertices = [
      const Offset(0.18, 0.24), // Top-left
      const Offset(0.82, 0.20), // Top-right
      const Offset(0.86, 0.74), // Bottom-right
      const Offset(0.22, 0.78), // Bottom-left
    ];
    _vertices = List.from(_initialVertices);
  }

  void _resetVertices() {
    setState(() {
      _vertices = List.from(_initialVertices);
    });
  }

  // Calculate dynamic rooftop area from vertex polygon
  int get _computedUsableAreaSqFt {
    // Gauss shoelace formula for normalized polygon area
    double area = 0.0;
    final n = _vertices.length;
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      area += _vertices[i].dx * _vertices[j].dy;
      area -= _vertices[j].dx * _vertices[i].dy;
    }
    area = area.abs() / 2.0;

    // Normalizing multiplier calibrated for ~1,245 sq ft baseline
    const baselineNormalizedArea = 0.3472;
    final ratio = (area / baselineNormalizedArea).clamp(0.7, 1.4);
    return (1245 * ratio).round();
  }

  double get _computedCapacityKwp {
    return (_computedUsableAreaSqFt / 200).clamp(3.0, 10.0);
  }

  int get _computedPanelCount {
    return (_computedUsableAreaSqFt / 88).round();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _handleProceed() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    Navigator.pushNamed(context, AppRoutes.aiRoofAnalysis);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Micro Stepper
            _buildProgressHeader(context),

            // Interactive Rooftop Boundary Canvas
            Expanded(child: _buildRooftopCanvas()),

            // Bottom Terrace Specs Bento Card & Action Controls
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.spaceSm,
        AppSpacing.margin,
        AppSpacing.spaceXs,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: AppRadii.full,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: AppColors.onSurface,
                  ),
                ),
              ),

              // Step Counter Capsule
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadii.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const PulsingDot(size: 7, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(
                      'Step 3 of 5 · Roof Boundary',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Sat vs 3D View Mode Toggle Pill
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadii.full,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleTab('Sat', !_is3DView, () {
                      setState(() => _is3DView = false);
                    }),
                    _buildToggleTab('3D', _is3DView, () {
                      setState(() => _is3DView = true);
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Micro Stepper Progress Bar (5 Steps)
          Row(
            children: [
              Expanded(child: _stepSegment(isComplete: true, isActive: false)),
              const SizedBox(width: 4),
              Expanded(child: _stepSegment(isComplete: true, isActive: false)),
              const SizedBox(width: 4),
              Expanded(child: _stepSegment(isComplete: false, isActive: true)),
              const SizedBox(width: 4),
              Expanded(child: _stepSegment(isComplete: false, isActive: false)),
              const SizedBox(width: 4),
              Expanded(child: _stepSegment(isComplete: false, isActive: false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.full,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadii.full,
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? AppColors.onPrimary
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _stepSegment({required bool isComplete, required bool isActive}) {
    if (isComplete) {
      return Container(
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: AppRadii.full,
        ),
      );
    }
    if (isActive) {
      return Container(
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.secondaryFixedDim,
          borderRadius: AppRadii.full,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: AppRadii.full,
              ),
            ),
          ),
        ),
      );
    }
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadii.full,
      ),
    );
  }

  Widget _buildRooftopCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;

        return ClipRect(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            transform: _is3DView
                ? (Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(0.22)
                    ..scaleByDouble(1.08, 1.08, 1.08, 1.0))
                : Matrix4.identity(),
            transformAlignment: Alignment.center,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. High-Resolution Terrace Aerial Satellite Image
                Transform.scale(
                  scale: _zoomScale,
                  child: Container(
                    color: const Color(0xFF2C3531),
                    child: CustomPaint(painter: _SimulatedTerracePainter()),
                  ),
                ),

                // 2. Solar Sunlight Vignette Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.25),
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.35),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // 3. Vector Polygon Rooftop & Water Tank Exclusion Overlay
                CustomPaint(
                  size: Size(canvasWidth, canvasHeight),
                  painter: _RooftopPolygonPainter(
                    vertices: _vertices,
                    zoomScale: _zoomScale,
                  ),
                ),

                // 4. Center Hero Rooftop Metric Badge
                _buildCenterMetricBadge(canvasWidth, canvasHeight),

                // 5. Water Tank Excluded Micro Floating Badge
                Positioned(
                  top: canvasHeight * 0.35,
                  right: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(
                        alpha: 0.95,
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
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Water Tank Excluded',
                          style: AppTypography.labelMd.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 6. Interactive Draggable Corner Vertex Pins
                ..._vertices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final normalizedOffset = entry.value;
                  return _buildDraggableHandle(
                    index: index,
                    offset: normalizedOffset,
                    canvasWidth: canvasWidth,
                    canvasHeight: canvasHeight,
                  );
                }),

                // 7. Top Instruction & Undo Bar
                Positioned(
                  top: 12,
                  left: AppSpacing.margin,
                  right: AppSpacing.margin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest.withValues(
                            alpha: 0.95,
                          ),
                          borderRadius: AppRadii.full,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✏️', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Text(
                              'Drag pins to match terrace parapet',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: _resetVertices,
                        borderRadius: AppRadii.full,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest.withValues(
                              alpha: 0.95,
                            ),
                            borderRadius: AppRadii.full,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.undo,
                                size: 14,
                                color: AppColors.onSurface,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Reset',
                                style: AppTypography.labelMd.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 8. Floating Map Utility Dock (North Needle, Zoom, Recenter)
                Positioned(
                  bottom: 12,
                  right: AppSpacing.margin,
                  child: Column(
                    children: [
                      // Compass North Needle
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest.withValues(
                            alpha: 0.95,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'N',
                              style: AppTypography.labelMd.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.error,
                                height: 1.0,
                              ),
                            ),
                            const Icon(
                              Icons.navigation,
                              size: 13,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Zoom Control Stack
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest.withValues(
                            alpha: 0.95,
                          ),
                          borderRadius: AppRadii.full,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _zoomScale = (_zoomScale + 0.15).clamp(
                                    0.85,
                                    1.8,
                                  );
                                });
                              },
                              borderRadius: AppRadii.full,
                              child: const SizedBox(
                                width: 36,
                                height: 32,
                                child: Icon(
                                  Icons.add,
                                  size: 17,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 1,
                              color: AppColors.outlineVariant,
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _zoomScale = (_zoomScale - 0.15).clamp(
                                    0.85,
                                    1.8,
                                  );
                                });
                              },
                              borderRadius: AppRadii.full,
                              child: const SizedBox(
                                width: 36,
                                height: 32,
                                child: Icon(
                                  Icons.remove,
                                  size: 17,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Recenter GPS Button
                      InkWell(
                        onTap: () {
                          setState(() {
                            _zoomScale = 1.0;
                            _is3DView = false;
                          });
                        },
                        borderRadius: AppRadii.full,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest.withValues(
                              alpha: 0.95,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            size: 17,
                            color: AppColors.primary,
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
    );
  }

  Widget _buildCenterMetricBadge(double width, double height) {
    // Calculate centroid of vertices
    double cx = 0.0;
    double cy = 0.0;
    for (final v in _vertices) {
      cx += v.dx;
      cy += v.dy;
    }
    cx = (cx / _vertices.length) * width;
    cy = (cy / _vertices.length) * height;

    return Positioned(
      left: cx - 100,
      top: cy - 42,
      child: IgnorePointer(
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withValues(
                    alpha: 0.98,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F164A38),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wb_sunny,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatNumber(_computedUsableAreaSqFt)} sq. ft',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1.5,
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
                            size: 11,
                            color: AppColors.onSecondaryContainer,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '94% Solar Viable',
                            style: AppTypography.labelMd.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Pointer tip
              CustomPaint(
                size: const Size(12, 6),
                painter: _TrianglePointerPainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableHandle({
    required int index,
    required Offset offset,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    final x = offset.dx * canvasWidth;
    final y = offset.dy * canvasHeight;

    return Positioned(
      left: x - 20,
      top: y - 20,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newDx = (details.globalPosition.dx / canvasWidth).clamp(
              0.05,
              0.95,
            );
            final newDy = (offset.dy + details.delta.dy / canvasHeight).clamp(
              0.08,
              0.92,
            );
            _vertices[index] = Offset(newDx, newDy);
          });
        },
        child: Container(
          width: 40,
          height: 40,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.spaceSm,
        AppSpacing.margin,
        AppSpacing.spaceSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Terrace Specs Bento Summary Card
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: AppRadii.card,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C164A38),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with high irradiance badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.roofing,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Terrace Analysis',
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Flat RCC Roof · Indiranagar 100ft Rd',
                              style: AppTypography.bodyMd.copyWith(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: AppRadii.full,
                      ),
                      child: Text(
                        'High Irradiance',
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),

                // 3 Key Solar Metrics Cards
                Row(
                  children: [
                    // Net Usable
                    Expanded(
                      child: _bentoStatTile(
                        label: 'Net Usable',
                        value: _formatNumber(_computedUsableAreaSqFt),
                        unit: 'sq. feet',
                        valueColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Max Power
                    Expanded(
                      child: _bentoStatTile(
                        label: 'Max Power',
                        value: '${_computedCapacityKwp.toStringAsFixed(1)} kWp',
                        unit: '~$_computedPanelCount Panels',
                        valueColor: AppColors.primary,
                        isHighlight: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Obstacles
                    Expanded(
                      child: _bentoStatTile(
                        label: 'Obstacles',
                        value: '1 Tank',
                        unit: '-115 sq. ft',
                        valueColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),

                // PM Surya Ghar Delight Note
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed.withValues(alpha: 0.35),
                    borderRadius: AppRadii.cardSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Qualifies for ₹78,000 central PM Surya Ghar DBT subsidy.',
                          style: AppTypography.bodyMd.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Primary CTA Button
          AppButton(
            label: _isAnalyzing
                ? 'Calibrating Solar Shadow...'
                : 'Use This Roof Boundary',
            isLoading: _isAnalyzing,
            showTrailingArrowBadge: true,
            onPressed: _handleProceed,
          ),
          const SizedBox(height: 2),

          // Secondary switch to camera
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.rooftopPhoto),
            borderRadius: AppRadii.full,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Switch to Camera Photo instead',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
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

  Widget _bentoStatTile({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.secondaryContainer.withValues(alpha: 0.4)
            : AppColors.surfaceContainer,
        borderRadius: AppRadii.cardSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelMd.copyWith(
              fontSize: 10,
              color: isHighlight
                  ? AppColors.secondary
                  : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.headlineSm.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            unit,
            style: AppTypography.labelMd.copyWith(
              fontSize: 9,
              color: isHighlight
                  ? AppColors.secondary
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter rendering the dynamic rooftop boundary and auto-excluded water tank obstacle.
class _RooftopPolygonPainter extends CustomPainter {
  final List<Offset> vertices;
  final double zoomScale;

  _RooftopPolygonPainter({required this.vertices, required this.zoomScale});

  @override
  void paint(Canvas canvas, Size size) {
    if (vertices.length < 3) return;

    final path = Path();
    path.moveTo(vertices[0].dx * size.width, vertices[0].dy * size.height);
    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx * size.width, vertices[i].dy * size.height);
    }
    path.close();

    // 1. Solar irradiance heat fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF9EF6AD).withValues(alpha: 0.4),
          const Color(0xFF82D993).withValues(alpha: 0.25),
          const Color(0xFFF0C03E).withValues(alpha: 0.35),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fillPaint);

    // 2. Solar photovoltaic panel module grid lines
    canvas.save();
    canvas.clipPath(path);
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    const gridStep = 22.0;
    for (double x = 0; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    canvas.restore();

    // 3. Dashed boundary perimeter outline
    final strokePaint = Paint()
      ..color = const Color(0xFF0B6D33)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);

    // 4. Excluded water tank obstacle polygon
    final tankRect = Rect.fromLTWH(
      size.width * 0.60,
      size.height * 0.32,
      size.width * 0.16,
      size.height * 0.12,
    );
    final tankPath = Path()
      ..addRRect(RRect.fromRectAndRadius(tankRect, const Radius.circular(4)));

    // Crimson hatch fill
    final hatchPaint = Paint()
      ..color = const Color(0xFFBA1A1A).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(tankPath, hatchPaint);

    final tankBorderPaint = Paint()
      ..color = const Color(0xFFBA1A1A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(tankPath, tankBorderPaint);

    // Excluded obstacle diagonal stripes
    canvas.save();
    canvas.clipPath(tankPath);
    final stripePaint = Paint()
      ..color = const Color(0xFFBA1A1A).withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    for (
      double i = -tankRect.height;
      i < tankRect.width + tankRect.height;
      i += 8
    ) {
      canvas.drawLine(
        Offset(tankRect.left + i, tankRect.top),
        Offset(tankRect.left + i + tankRect.height, tankRect.bottom),
        stripePaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RooftopPolygonPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.zoomScale != zoomScale;
  }
}

/// Downward triangle pointer for center metric badge.
class _TrianglePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceContainerLowest
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SimulatedTerracePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Aerial city ground
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF2E3A34),
    );

    // Green neem canopy around roof
    final treePaint = Paint()..color = const Color(0xFF1E3827);
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.15),
      45,
      treePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.85),
      55,
      treePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.18),
      40,
      treePaint,
    );

    // Large main Indiranagar flat concrete terrace roof
    final roofRect = Rect.fromCenter(
      center: Offset(size.width * 0.52, size.height * 0.49),
      width: size.width * 0.76,
      height: size.height * 0.62,
    );
    // Rooftop drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        roofRect.translate(6, 12),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0x33000000),
    );
    // Concrete roof surface
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFFC8BCA8),
    );

    // Terrace parapet border
    final parapetPaint = Paint()
      ..color = const Color(0xFFB5A792)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(8)),
      parapetPaint,
    );

    // Mumty / Stairwell room
    final mumtyRect = Rect.fromLTWH(
      roofRect.left + roofRect.width * 0.58,
      roofRect.top + roofRect.height * 0.16,
      roofRect.width * 0.26,
      roofRect.height * 0.28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        mumtyRect.translate(3, 4),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0x2A000000),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mumtyRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFDFD7CA),
    );

    // Overhead sintex water tank
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
