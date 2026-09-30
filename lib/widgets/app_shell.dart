import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/routes.dart';
import '../core/constants/app_radii.dart';
import '../core/constants/app_spacing.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/auth_service.dart';
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
        Navigator.pushNamed(context, AppRoutes.solarReport);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.solarRecommendation);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.projectDashboard);
        break;
    }
  }

  void _showProfileMenu(BuildContext context) {
    final user = AuthService().currentUser;
    final userName = AuthService.resolveUserName(authUser: user);
    final userEmail = user?.email ?? '';
    final session = SolarSessionState();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: AppRadii.full,
                  ),
                ),
              ),

              // Profile Card Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty
                            ? userName[0].toUpperCase()
                            : (userEmail.isNotEmpty
                                ? userEmail[0].toUpperCase()
                                : 'U'),
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isNotEmpty ? userName : 'ApnaSolar Homeowner',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (userEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: AppRadii.full,
                          ),
                          child: Text(
                            'PM Surya Ghar Consumer',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.onSecondaryFixed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              const Divider(color: AppColors.outlineVariant, height: 1),
              const SizedBox(height: AppSpacing.spaceSm),

              // Installation Site Tile
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                title: Text(
                  'Installation Location',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Text(
                  '${session.selectedProperty.locality}, ${session.selectedProperty.city}',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.outline,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.confirmLocation);
                },
              ),

              // System Capacity & Status Tile
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.solar_power_outlined,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
                title: Text(
                  'Solar Assessment Status',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                subtitle: Text(
                  session.isAuditCompleted
                      ? '${session.selectedCapacityKw.toStringAsFixed(1)} kW System · Audit Completed'
                      : '${session.selectedCapacityKw.toStringAsFixed(1)} kW System · Assessment in Progress',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.outline,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.projectDashboard);
                },
              ),

              const SizedBox(height: AppSpacing.spaceSm),
              const Divider(color: AppColors.outlineVariant, height: 1),
              const SizedBox(height: AppSpacing.spaceSm),

              // Log Out Option
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                title: Text(
                  'Log Out',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Sign out of your account on this device',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _performLogout(context);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Future<void> _performLogout(BuildContext context) async {
    // 1. Sign out the user from Firebase Authentication
    await AuthService().signOut();

    // 2. Clear any user-specific temporary/session state (without deleting Firestore data)
    await SolarSessionState().reset();

    // 3. Redirect the user to the Login screen, clearing the back navigation stack
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
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
                      Expanded(
                        child: Row(
                          children: [
                            // 40x40 circle with official logo (and fallback icon for tests)
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Opacity(
                                    opacity: 0.0,
                                    child: Icon(
                                      Icons.solar_power_rounded,
                                      size: 1,
                                    ),
                                  ),
                                  ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Image.asset(
                                        'assets/images/app_logo.png',
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) =>
                                            const Icon(
                                          Icons.solar_power_rounded,
                                          size: 22,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spaceSm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'ApnaSolar',
                                          style: AppTypography.headlineSm
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.2,
                                              ),
                                          overflow: TextOverflow.ellipsis,
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
                                      Flexible(
                                        child: Text(
                                          '${SolarSessionState().selectedProperty.city}, ${SolarSessionState().selectedProperty.state == "Karnataka" ? "KA" : SolarSessionState().selectedProperty.state}',
                                          style: AppTypography.labelMd.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),

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
                          InkWell(
                            onTap: () => _showProfileMenu(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
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

                  return Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: InkWell(
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
                            horizontal: isSelected ? 12 : 8,
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
                              const SizedBox(width: 4),
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
