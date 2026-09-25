import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import 'status_badge.dart';

/// Top flow header bar for multistep flows (e.g. Location, Rooftop Drawing, Analysis).
/// Renders a frosted back button, step milestone badge pill, and optional trailing action button.
class AppFlowHeader extends StatelessWidget {
  final String stepText;
  final VoidCallback? onBack;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? actionTooltip;
  final bool isActionActive;

  const AppFlowHeader({
    super.key,
    required this.stepText,
    this.onBack,
    this.actionIcon,
    this.onAction,
    this.actionTooltip,
    this.isActionActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Frosted Back Button
          _FrostedIconButton(
            icon: Icons.arrow_back,
            tooltip: 'Go Back',
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),

          // Step Badge Pill
          StatusBadge(
            label: stepText,
            variant: StatusBadgeVariant.glass,
            hasPulseDot: true,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),

          // Optional Trailing Action (e.g. Satellite layer toggle)
          if (actionIcon != null)
            _FrostedIconButton(
              icon: actionIcon!,
              tooltip: actionTooltip,
              isActive: isActionActive,
              onTap: onAction,
            )
          else
            const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}

class _FrostedIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  const _FrostedIconButton({
    required this.icon,
    this.tooltip,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.90),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x10164A38),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isActive ? AppColors.secondary : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
