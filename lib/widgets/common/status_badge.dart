import 'package:flutter/material.dart';

import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum StatusBadgeVariant {
  green,
  amber,
  primary,
  secondaryFixed,
  neutral,
  glass,
  error,
}

/// Pill-shaped badge for statuses, tags, step milestones, and certifications matching Stitch.
class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final StatusBadgeVariant variant;
  final bool hasPulseDot;
  final double fontSize;
  final FontWeight fontWeight;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    this.variant = StatusBadgeVariant.green,
    this.hasPulseDot = false,
    this.fontSize = 12.0,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    List<BoxShadow>? shadows;

    switch (variant) {
      case StatusBadgeVariant.green:
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        break;
      case StatusBadgeVariant.amber:
        bg = AppColors.tertiaryFixed;
        fg = AppColors.onTertiaryFixedVariant;
        break;
      case StatusBadgeVariant.primary:
        bg = AppColors.primaryFixed;
        fg = AppColors.onPrimaryFixed;
        break;
      case StatusBadgeVariant.secondaryFixed:
        bg = AppColors.secondaryFixed;
        fg = AppColors.onSecondaryFixed;
        shadows = const [
          BoxShadow(
            color: Color(0x1A0B6D33),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ];
        break;
      case StatusBadgeVariant.neutral:
        bg = AppColors.surfaceContainer;
        fg = AppColors.onSurfaceVariant;
        break;
      case StatusBadgeVariant.glass:
        bg = AppColors.surfaceContainerLowest.withValues(alpha: 0.90);
        fg = AppColors.primary;
        shadows = const [
          BoxShadow(
            color: Color(0x10164A38),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ];
        break;
      case StatusBadgeVariant.error:
        bg = AppColors.errorContainer;
        fg = AppColors.onErrorContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.full,
        boxShadow: shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPulseDot) ...[
            const PulsingDot(),
            const SizedBox(width: AppSpacing.spaceXs + 2),
          ],
          if (icon != null) ...[
            Icon(icon, size: fontSize + 3, color: fg),
            const SizedBox(width: AppSpacing.spaceXs + 1),
          ],
          Text(
            label,
            style: AppTypography.labelMd.copyWith(
              color: fg,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle pulsing green dot for live status indicators matching Stitch animate-pulse.
class PulsingDot extends StatefulWidget {
  final double size;
  final Color color;

  const PulsingDot({
    super.key,
    this.size = 8.0,
    this.color = AppColors.secondary,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
