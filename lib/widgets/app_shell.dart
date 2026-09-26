import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/routes.dart';
import '../core/constants/app_radii.dart';
import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/solar_session_service.dart';

/// AppShell provides the Stitch-spec global frosted header and floating bottom navigation bar.
class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final bool showHeader;
  final bool showBottomNav;
  final bool showBackButton;
  final String? title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const AppShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.showHeader = true,
    this.showBottomNav = true,
    this.showBackButton = false,
    this.title,
    this.actions,
    this.onBack,
  });

  void _onNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    HapticFeedback.selectionClick();

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.confirmLocation);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.solarRecommendation);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.projectDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      extendBody: true,
      appBar: showHeader ? _buildHeader(context) : null,
      body: child,
      bottomNavigationBar: showBottomNav
          ? _buildFloatingBottomNav(context)
          : null,
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64.0),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.85),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08164A38),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 64.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.margin,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Back button OR Brand logo + location
                    if (showBackButton)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CircularGlassButton(
                            icon: Icons.arrow_back,
                            onTap: onBack ?? () => Navigator.of(context).pop(),
                          ),
                          if (title != null) ...[
                            const SizedBox(width: AppSpacing.spaceSm),
                            Text(
                              title!,
                              style: AppTypography.headlineSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 40x40 Primary container circle with solar power icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.solar_power_rounded,
                                size: 22,
                                color: AppColors.secondaryFixed,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spaceSm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ApnaSolar',
                                    style: AppTypography.headlineSm.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppColors.secondary,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 13,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${SolarSessionState().selectedProperty.city}, ${SolarSessionState().selectedProperty.state == "Karnataka" ? "KA" : SolarSessionState().selectedProperty.state}',
                                    style: AppTypography.labelMd.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.expand_more,
                                    size: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                    // Right: Actions (Notifications + User profile avatar)
                    if (actions != null)
                      Row(mainAxisSize: MainAxisSize.min, children: actions!)
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Notifications 44x44 circular button
                          _CircularGlassButton(
                            icon: Icons.notifications_outlined,
                            size: 44,
                            iconSize: 22,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No new notifications'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: AppSpacing.spaceSm),
                          // User Profile Avatar 32x32
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x20003323),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    final navItems = [
      const _NavItem(icon: Icons.home_rounded, label: 'Home'),
      const _NavItem(icon: Icons.wb_sunny_rounded, label: 'Assess'),
      const _NavItem(icon: Icons.currency_rupee_rounded, label: 'Savings'),
      const _NavItem(icon: Icons.checklist_rounded, label: 'Projects'),
    ];

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.margin,
          0,
          AppSpacing.margin,
          8,
        ),
        child: ClipRRect(
          borderRadius: AppRadii.full,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.90),
                borderRadius: AppRadii.full,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A164A38),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final isSelected = index == currentIndex;
                  final item = navItems[index];

                  return InkWell(
                    onTap: () => _onNavTap(context, index),
                    borderRadius: AppRadii.full,
                    splashColor: AppColors.secondaryFixed.withValues(
                      alpha: 0.2,
                    ),
                    highlightColor: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 14 : 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryContainer
                            : Colors.transparent,
                        borderRadius: AppRadii.full,
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x33164A38),
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? AppColors.secondaryFixed
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.label,
                            style: AppTypography.labelMd.copyWith(
                              color: isSelected
                                  ? AppColors.secondaryFixed
                                  : AppColors.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _CircularGlassButton({
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.65),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
