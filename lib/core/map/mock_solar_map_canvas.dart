import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_radii.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'map_provider_interface.dart';

/// Interactive solar map canvas faithful to the Stitch prototype design.
/// Supports vector schematic rendering and simulated satellite aerial photography,
/// isolated behind the [SolarMapProvider] abstraction.
class MockSolarMapCanvas extends StatelessWidget implements SolarMapProvider {
  final SolarMapController controller;
  final ValueChanged<Offset>? onPinMoved;

  const MockSolarMapCanvas({
    super.key,
    required this.controller,
    this.onPinMoved,
  });

  @override
  Widget buildMapWidget({
    required BuildContext context,
    required SolarMapController controller,
    required ValueChanged<Offset> onPinMoved,
  }) {
    return MockSolarMapCanvas(controller: controller, onPinMoved: onPinMoved);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: AppRadii.card,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Map Viewport with interactive tap to place pin
              LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTapUp: (details) {
                      final dx =
                          details.localPosition.dx / constraints.maxWidth;
                      final dy =
                          details.localPosition.dy / constraints.maxHeight;
                      final offset = Offset(dx, dy);
                      controller.updatePinPosition(offset);
                      onPinMoved?.call(offset);
                    },
                    child: Stack(
                      children: [
                        // Layer 1: Vector Schematic Base Canvas
                        Positioned.fill(
                          child: Transform.scale(
                            scale: controller.zoomLevel,
                            child: CustomPaint(
                              painter: _VectorSolarMapPainter(),
                            ),
                          ),
                        ),

                        // Layer 2: Simulated Satellite Photo (Toggled via layer switch)
                        Positioned.fill(
                          child: AnimatedOpacity(
                            opacity: controller.mode != SolarMapMode.vector
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 400),
                            child: Transform.scale(
                              scale: controller.zoomLevel,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Satellite photo simulation (offline procedural painter)
                                  Container(
                                    color: const Color(0xFF38433E),
                                    child: CustomPaint(
                                      painter: _SimulatedSatellitePainter(),
                                    ),
                                  ),
                                  // Ambient solar warmth filter
                                  Container(
                                    color: AppColors.primaryContainer
                                        .withValues(alpha: 0.15),
                                  ),
                                  // Center solar irradiance radial overlay
                                  Center(
                                    child: Container(
                                      width: 280,
                                      height: 280,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.tertiaryFixed.withValues(
                                              alpha: 0.45,
                                            ),
                                            AppColors.secondaryContainer
                                                .withValues(alpha: 0.2),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.55, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Layer 3: Interactive Solar Pin Marker
                        _buildPinMarker(constraints),
                      ],
                    ),
                  );
                },
              ),

              // Prototype Map Mode Disclaimer Pill
              if (controller.mode != SolarMapMode.vector)
                Positioned(
                  bottom: 8,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: AppRadii.full,
                    ),
                    child: Text(
                      'Satellite simulation · Bengaluru calibrated',
                      style: AppTypography.labelMd.copyWith(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinMarker(BoxConstraints constraints) {
    final x = controller.pinNormalizedOffset.dx * constraints.maxWidth;
    final y = controller.pinNormalizedOffset.dy * constraints.maxHeight;

    return Positioned(
      left: x - 80,
      top: y - 76,
      child: IgnorePointer(
        child: SizedBox(
          width: 160,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge above Pin
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.full,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33003323),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.solar_power,
                      size: 13,
                      color: AppColors.secondaryFixed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Your Rooftop',
                      style: AppTypography.labelMd.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Pin Marker with pulsing aura
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixedDim.withValues(
                        alpha: 0.35,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 20,
                      color: AppColors.secondaryFixed,
                    ),
                  ),
                ],
              ),

              // Ground shadow dot
              Container(
                width: 14,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: AppRadii.full,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter rendering the Stitch vector map schematic.
class _VectorSolarMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Terrain
    final bgPaint = Paint()..color = const Color(0xFFF7F4EA);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Road Grid Pattern
    final gridPaint = Paint()
      ..color = const Color(0xFFEBE8DE)
      ..strokeWidth = 1.0;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Canopy Greens / Park Areas
    final parkPaint = Paint()
      ..color = const Color(0xFF9BF3AA).withValues(alpha: 0.45);
    final treePaint = Paint()
      ..color = const Color(0xFF0B6D33).withValues(alpha: 0.35);

    final parkPath1 = Path()
      ..moveTo(size.width * 0.05, size.height * 0.05)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.04,
        size.width * 0.3,
        size.height * 0.16,
      )
      ..close();
    canvas.drawPath(parkPath1, parkPaint);
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.09),
      12,
      treePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.12),
      16,
      treePaint,
    );

    final parkPath2 = Path()
      ..moveTo(size.width * 0.7, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.7,
        size.width * 0.95,
        size.height * 0.92,
      )
      ..close();
    canvas.drawPath(parkPath2, parkPaint);
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.82),
      16,
      treePaint,
    );

    // 4. Neighborhood Avenues & Roads (White highway bands)
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = const Color(0xFFE5E2D9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Horizontal avenue (HAL 2nd Stage)
    final avenuePath = Path()
      ..moveTo(-20, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width + 20,
        size.height * 0.22,
      );
    canvas.drawPath(avenuePath, roadPaint);
    canvas.drawPath(avenuePath, dashPaint);

    // Vertical Main Road (14th Main Road)
    final mainRoadPath = Path()
      ..moveTo(size.width * 0.52, -20)
      ..lineTo(size.width * 0.52, size.height + 20);
    final verticalRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 34
      ..style = PaintingStyle.stroke;
    canvas.drawPath(mainRoadPath, verticalRoadPaint);
    canvas.drawPath(mainRoadPath, dashPaint);

    // 5. Neighboring Rooftops
    final buildingPaint = Paint()..color = Colors.white;
    final buildingShadowPaint = Paint()..color = const Color(0x14164A38);

    void drawBuilding(Rect rect) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.translate(0, 3), const Radius.circular(6)),
        buildingShadowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        buildingPaint,
      );
    }

    // North block
    drawBuilding(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.36,
        size.width * 0.16,
        size.height * 0.08,
      ),
    );
    drawBuilding(
      Rect.fromLTWH(
        size.width * 0.29,
        size.height * 0.35,
        size.width * 0.18,
        size.height * 0.09,
      ),
    );
    // East block
    drawBuilding(
      Rect.fromLTWH(
        size.width * 0.62,
        size.height * 0.32,
        size.width * 0.16,
        size.height * 0.09,
      ),
    );
    drawBuilding(
      Rect.fromLTWH(
        size.width * 0.81,
        size.height * 0.34,
        size.width * 0.14,
        size.height * 0.08,
      ),
    );
    // South-east block
    drawBuilding(
      Rect.fromLTWH(
        size.width * 0.62,
        size.height * 0.52,
        size.width * 0.18,
        size.height * 0.12,
      ),
    );
    drawBuilding(
      Rect.fromLTWH(
        size.width * 0.82,
        size.height * 0.54,
        size.width * 0.14,
        size.height * 0.11,
      ),
    );

    // 6. Target Home Rooftop (Directly at center)
    final targetRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.51),
      width: size.width * 0.28,
      height: size.height * 0.15,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        targetRect.translate(0, 6),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0x24164A38),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect, const Radius.circular(10)),
      Paint()..color = Colors.white,
    );

    // Parapets and terrace zones
    final innerTerrace = Rect.fromLTWH(
      targetRect.left + 6,
      targetRect.top + 6,
      targetRect.width * 0.45,
      targetRect.height - 12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerTerrace, const Radius.circular(4)),
      Paint()..color = const Color(0xFFF7F4EA),
    );

    // Optimal Solar Absorption Area inside Target Home
    final solarZone = Rect.fromLTWH(
      targetRect.left + targetRect.width * 0.52,
      targetRect.top + targetRect.height * 0.45,
      targetRect.width * 0.42,
      targetRect.height * 0.45,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(solarZone, const Radius.circular(4)),
      Paint()..color = AppColors.tertiaryFixed.withValues(alpha: 0.65),
    );

    // Solar water heater dot
    canvas.drawCircle(
      Offset(targetRect.left + 16, targetRect.top + 16),
      5,
      Paint()..color = AppColors.secondaryFixedDim,
    );

    // 7. Ambient Solar Radiation Radial Glow Overlay
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.tertiaryFixed.withValues(alpha: 0.75),
              AppColors.secondaryContainer.withValues(alpha: 0.2),
              Colors.transparent,
            ],
            stops: const [0.0, 0.55, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.51),
              radius: math.min(size.width, size.height) * 0.45,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.51),
      math.min(size.width, size.height) * 0.45,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SimulatedSatellitePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base terrain
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF3B4840),
    );

    // Roads
    final roadPaint = Paint()
      ..color = const Color(0xFF262D2A)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(-10, size.height * 0.28),
      Offset(size.width + 10, size.height * 0.22),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.52, -10),
      Offset(size.width * 0.52, size.height + 10),
      roadPaint,
    );

    // Green tree clusters
    final canopyPaint = Paint()..color = const Color(0xFF1E3827);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.1),
      32,
      canopyPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.8),
      38,
      canopyPaint,
    );

    // Neighbor rooftops
    final roofPaint = Paint()..color = const Color(0xFFC7BBAA);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.36,
          size.width * 0.16,
          size.height * 0.08,
        ),
        const Radius.circular(4),
      ),
      roofPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.62,
          size.height * 0.32,
          size.width * 0.16,
          size.height * 0.09,
        ),
        const Radius.circular(4),
      ),
      roofPaint,
    );

    // Target roof
    final targetPaint = Paint()..color = const Color(0xFFD4C8B8);
    final targetRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.51),
      width: size.width * 0.3,
      height: size.height * 0.16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect, const Radius.circular(6)),
      targetPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
