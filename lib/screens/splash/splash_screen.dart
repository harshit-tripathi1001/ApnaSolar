import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/auth_service.dart';
import '../../services/solar_session_service.dart';

/// Splash Screen (Stitch: f4b18c32c78e42be85884309e02ae389)
/// Displays Indian ambient region marker, central solar roof hero canvas,
/// trust badges, animated progress bar, and "Check My Rooftop" CTA.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _navTimer;
  Timer? _progressStepTimer;
  late final AnimationController _rayPulseController;

  int _stepIndex = 0;
  final List<String> _progressSteps = [
    'Measuring rooftop sunlight...',
    'Locating city solar irradiation...',
    'Calculating Central Govt subsidy...',
    'Your sunny rooftop is ready!',
  ];

  void _navigateNext() {
    _navTimer?.cancel();
    _progressStepTimer?.cancel();
    if (mounted) {
      if (AuthService().isSignedIn) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _rayPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _progressStepTimer = Timer.periodic(const Duration(milliseconds: 450), (
      timer,
    ) {
      if (!mounted) return;
      setState(() {
        if (_stepIndex < _progressSteps.length - 1) {
          _stepIndex++;
        }
      });
    });

    // Pre-load most recent Firestore analysis during the splash delay
    SolarSessionState().loadFromFirestore();

    _navTimer = Timer(const Duration(milliseconds: 1800), _navigateNext);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _progressStepTimer?.cancel();
    _rayPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = (_stepIndex + 1) / _progressSteps.length;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _navigateNext,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.margin,
                        vertical: AppSpacing.spaceSm,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Subtle Ambient Top Status / Region Marker
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
                                        Icons.wb_sunny_rounded,
                                        size: 16,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: AppSpacing.spaceXs),
                                      Text(
                                        'SURYA URJA • INDIA',
                                        style: AppTypography.labelMd.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          letterSpacing: 0.8,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer
                                        .withValues(alpha: 0.5),
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
                                      const SizedBox(width: 5),
                                      Text(
                                        'PM Surya Ghar Active',
                                        style: AppTypography.labelMd.copyWith(
                                          color: AppColors.onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.spaceSm),

                          // 2. Central Visual Delight Hero Canvas
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              maxWidth: 340,
                              maxHeight: 280,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12164A38),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Atmospheric Radiant Aura
                                Positioned(
                                  top: 10,
                                  child: Container(
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.tertiaryFixed.withValues(
                                            alpha: 0.55,
                                          ),
                                          AppColors.secondaryContainer
                                              .withValues(alpha: 0.25),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Custom Painted Sun & Solar Roof Illustration
                                AnimatedBuilder(
                                  animation: _rayPulseController,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      size: const Size(260, 210),
                                      painter: _SolarHeroCanvasPainter(
                                        pulseValue: _rayPulseController.value,
                                      ),
                                    );
                                  },
                                ),
                                // Micro Counter Badge
                                Positioned(
                                  bottom: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerHigh
                                          .withValues(alpha: 0.9),
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
                                          Icons.bolt_rounded,
                                          size: 15,
                                          color: AppColors.secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Up to ₹48,000 yearly grid savings',
                                          style: AppTypography.labelMd.copyWith(
                                            color: AppColors.onSurface,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.spaceSm),

                          // 3. Brand Section
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.solar_power_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Apna',
                                      style: AppTypography.headlineLgMobile
                                          .copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                      children: [
                                        TextSpan(
                                          text: 'Solar',
                                          style: TextStyle(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.spaceXs),
                              Text(
                                'Solar made simple for every Indian home.',
                                style: AppTypography.bodyLg.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Know your roof. Know your savings.',
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.75,
                                  ),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.spaceSm),
                              // Cultural Trust Badges
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainer,
                                      borderRadius: AppRadii.full,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.verified_rounded,
                                          size: 14,
                                          color: AppColors.secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'MNRE Empanelled',
                                          style: AppTypography.labelMd.copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
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
                                      color: AppColors.surfaceContainer,
                                      borderRadius: AppRadii.full,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.currency_rupee_rounded,
                                          size: 14,
                                          color: Color(0xFFF0C03E),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '₹78,000 Direct Subsidy',
                                          style: AppTypography.labelMd.copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.spaceSm),

                          // 4. Progress Indicator & Playful Microcopy
                          Column(
                            children: [
                              Container(
                                width: 220,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: AppRadii.full,
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progressValue,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: AppRadii.full,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryFixedDim,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Text(
                                    _progressSteps[_stepIndex],
                                    style: AppTypography.labelMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.spaceSm),

                          // 5. Check My Rooftop Button
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _navigateNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Check My Rooftop',
                                      style: AppTypography.labelLg.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering the Stitch splash rising sun, beam, clay roof gable, and solar panels.
class _SolarHeroCanvasPainter extends CustomPainter {
  final double pulseValue;

  _SolarHeroCanvasPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const sunY = 56.0;

    // 1. Ambient Ray circles
    final rayPaint = Paint()
      ..color = const Color(
        0xFFFFDF95,
      ).withValues(alpha: 0.25 + 0.15 * pulseValue)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, sunY), 46 + 4 * pulseValue, rayPaint);

    final innerRayPaint = Paint()
      ..color = const Color(0xFFFFDF95).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, sunY), 34, innerRayPaint);

    // 2. Dashed Ray lines
    final linePaint = Paint()
      ..color = const Color(0xFFF0C03E).withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, sunY - 40), Offset(cx, sunY - 48), linePaint);
    canvas.drawLine(
      Offset(cx + 36, sunY - 26),
      Offset(cx + 44, sunY - 32),
      linePaint,
    );
    canvas.drawLine(
      Offset(cx - 36, sunY - 26),
      Offset(cx - 44, sunY - 32),
      linePaint,
    );
    canvas.drawLine(Offset(cx + 48, sunY), Offset(cx + 56, sunY), linePaint);
    canvas.drawLine(Offset(cx - 48, sunY), Offset(cx - 56, sunY), linePaint);

    // 3. Rising Golden Sun
    final sunShader = const RadialGradient(
      colors: [Color(0xFFFFDF95), Color(0xFFF0C03E), Color(0xFFD5A825)],
      stops: [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, sunY), radius: 24));

    final sunPaint = Paint()
      ..shader = sunShader
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, sunY), 24, sunPaint);

    // 4. Downward Warm Light Beam
    final beamPath = Path()
      ..moveTo(cx, sunY)
      ..lineTo(cx - 85, 150)
      ..lineTo(cx + 85, 150)
      ..close();
    final beamPaint = Paint()
      ..color = const Color(0xFFFFDF95).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(beamPath, beamPaint);

    // 5. Pitched Roof Gable (Clay Tile)
    const roofApexY = 100.0;
    const roofBaseY = 155.0;
    final roofPath = Path()
      ..moveTo(cx, roofApexY)
      ..lineTo(cx - 100, roofBaseY)
      ..lineTo(cx + 100, roofBaseY)
      ..close();

    final roofShader =
        const LinearGradient(
          colors: [Color(0xFFD97757), Color(0xFFB85333)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(cx - 100, roofApexY, 200, roofBaseY - roofApexY),
        );

    final roofPaint = Paint()..shader = roofShader;
    canvas.drawPath(roofPath, roofPaint);

    // Eaves Overhang Base
    final basePaint = Paint()..color = const Color(0xFFDDDAD0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 85, roofBaseY, 170, 16),
        const Radius.circular(3),
      ),
      basePaint,
    );

    // 6. Left and Right Solar Panels with Angle
    _drawPanel(canvas, Offset(cx - 45, 125), angle: -0.10);
    _drawPanel(canvas, Offset(cx + 45, 125), angle: 0.10);

    // 7. Leaf Spark Badge in Center
    final badgeCenter = Offset(cx, 102);
    final badgeCirclePaint = Paint()..color = const Color(0xFF0B6D33);
    canvas.drawCircle(badgeCenter, 10, badgeCirclePaint);

    final leafPaint = Paint()
      ..color = const Color(0xFF9EF6AD)
      ..style = PaintingStyle.fill;
    final leafPath = Path()
      ..moveTo(badgeCenter.dx, badgeCenter.dy - 5)
      ..quadraticBezierTo(
        badgeCenter.dx + 4,
        badgeCenter.dy - 1,
        badgeCenter.dx + 3,
        badgeCenter.dy + 3,
      )
      ..quadraticBezierTo(
        badgeCenter.dx,
        badgeCenter.dy + 5,
        badgeCenter.dx,
        badgeCenter.dy + 5,
      )
      ..quadraticBezierTo(
        badgeCenter.dx,
        badgeCenter.dy + 5,
        badgeCenter.dx - 3,
        badgeCenter.dy + 3,
      )
      ..quadraticBezierTo(
        badgeCenter.dx - 4,
        badgeCenter.dy - 1,
        badgeCenter.dx,
        badgeCenter.dy - 5,
      )
      ..close();
    canvas.drawPath(leafPath, leafPaint);
  }

  void _drawPanel(Canvas canvas, Offset center, {required double angle}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final rect = Rect.fromCenter(center: Offset.zero, width: 48, height: 34);

    final panelShader = const LinearGradient(
      colors: [Color(0xFF164A38), Color(0xFF003323), Color(0xFF0B6D33)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

    final fillPaint = Paint()..shader = panelShader;
    final borderPaint = Paint()
      ..color = const Color(0xFF9EF6AD)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      borderPaint,
    );

    // Grid lines
    final linePaint = Paint()
      ..color = const Color(0xFF9EF6AD).withValues(alpha: 0.6)
      ..strokeWidth = 0.6;

    // Horizontal line
    canvas.drawLine(Offset(rect.left, 0), Offset(rect.right, 0), linePaint);
    // Vertical lines
    canvas.drawLine(Offset(-8, rect.top), Offset(-8, rect.bottom), linePaint);
    canvas.drawLine(Offset(8, rect.top), Offset(8, rect.bottom), linePaint);

    // Glint
    final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    canvas.drawCircle(Offset(rect.left + 8, rect.top + 6), 1.8, glintPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SolarHeroCanvasPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
