import 'package:flutter/material.dart';

import '../app/routes.dart';
import '../core/constants/app_radii.dart';
import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// AppShell provides the common header and floating bottom navigation bar.
class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final bool showHeader;
  final bool showBottomNav;

  const AppShell({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.showHeader = true,
    this.showBottomNav = true,
  });

  void _onNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;
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
      appBar: showHeader ? _buildHeader(context) : null,
      body: child,
      bottomNavigationBar: showBottomNav
          ? _buildFloatingBottomNav(context)
          : null,
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
      elevation: 0,
      titleSpacing: AppSpacing.margin,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.solar_power_rounded,
              size: 20,
              color: AppColors.secondaryFixed,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
                    size: 15,
                    color: AppColors.secondary,
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Bengaluru, KA',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
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
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.onSurfaceVariant,
          ),
          onPressed: () {},
        ),
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: AppSpacing.margin),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 18, color: AppColors.onPrimary),
        ),
      ],
    );
  }

  Widget _buildFloatingBottomNav(BuildContext context) {
    final navItems = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.wb_sunny_rounded, label: 'Assess'),
      _NavItem(icon: Icons.currency_rupee_rounded, label: 'Savings'),
      _NavItem(icon: Icons.checklist_rounded, label: 'Projects'),
    ];

    return SafeArea(
      child: Container(
        height: 68,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.margin,
          0,
          AppSpacing.margin,
          8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
          borderRadius: AppRadii.full,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowElevated,
              blurRadius: 28,
              offset: Offset(0, 10),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 12,
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
                            blurRadius: 10,
                            offset: Offset(0, 4),
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
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.secondaryFixed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
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
