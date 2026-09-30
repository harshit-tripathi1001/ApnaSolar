import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/installer_provider.dart';
import '../../services/solar_session_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

/// Project Dashboard Screen (Stitch: 7f53150992bc4caf908408ffe0795067)
/// Tab 3 in AppShell: Displays the user's actual persistent solar project,
/// engineering specs, financial subsidy breakdown, and selected verified installer.
class ProjectDashboardScreen extends StatelessWidget {
  const ProjectDashboardScreen({super.key});

  String _formatCurrency(num amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final prop = session.selectedProperty;
    final financials = session.financialBreakdown;
    final solar = session.solarEstimate;
    final roof = session.rooftopAnalysis;
    final installer = session.selectedInstaller;
    final capacity = session.selectedCapacityKw.toStringAsFixed(1);
    final displayAddress = session.hasUserSetLocation
        ? prop.formattedAddress
        : (prop.formattedAddress.isNotEmpty
              ? prop.formattedAddress
              : 'Not provided yet');

    return AppShell(
      currentIndex: 3,
      showHeader: false,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            AppSpacing.spaceSm,
            AppSpacing.margin,
            90, // Spacing above floating bottom nav
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Title & Status Banner ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Tracker',
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Real-time deployment & audit status',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: installer != null
                          ? AppColors.secondaryContainer.withValues(alpha: 0.6)
                          : AppColors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: AppRadii.full,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          installer != null
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_top_rounded,
                          size: 13,
                          color: installer != null
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          installer != null
                              ? 'INSTALLER CONNECTED'
                              : 'AUDIT COMPLETED',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: installer != null
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMd),

              // ── 1. Property Location Record ──────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(
                              alpha: 0.4,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Installation Property',
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                displayAddress,
                                style: AppTypography.bodyMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.outlineVariant),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoPill(
                          'GPS',
                          '${prop.latitude.toStringAsFixed(3)}, ${prop.longitude.toStringAsFixed(3)}',
                        ),
                        _infoPill('Structure', session.propertyType),
                        _infoPill('Roof', session.roofType),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),

              // ── 2. Engineering & Technical Specs Bento ───────────────────
              Row(
                children: [
                  Expanded(
                    child: _specBox(
                      title: 'System Sizing',
                      value: '$capacity kW',
                      subtitle: '${solar.panelCount} Tier-1 Panels',
                      icon: Icons.solar_power_rounded,
                      accentColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: _specBox(
                      title: 'Usable Rooftop',
                      value: '${roof.netUsableAreaSqFt.toInt()} sq ft',
                      subtitle:
                          '${roof.solarViabilityPercent.toInt()}% solar viability',
                      icon: Icons.roofing_rounded,
                      accentColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Row(
                children: [
                  Expanded(
                    child: _specBox(
                      title: 'Estimated Yield',
                      value: '~${solar.annualGenerationKwh.toInt()} kWh',
                      subtitle: 'per year clean generation',
                      icon: Icons.bolt_rounded,
                      accentColor: const Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Expanded(
                    child: _specBox(
                      title: 'CO₂ Avoided',
                      value:
                          '${solar.co2OffsetTonnesPerYear.toStringAsFixed(1)} T/yr',
                      subtitle:
                          'Equivalent to ${solar.treeOffsetEquivalent} trees',
                      icon: Icons.forest_rounded,
                      accentColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMd),

              // ── 3. Financial & Subsidy Breakdown ─────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial & Subsidy Breakdown',
                      style: AppTypography.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _financialRow(
                      'Gross Turnkey Project Cost',
                      '₹${_formatCurrency(financials.grossTurnkeyCost)}',
                    ),
                    _financialRow(
                      'PM Surya Ghar DBT Subsidy',
                      '-₹${_formatCurrency(financials.centralDbtSubsidy)}',
                      valueColor: AppColors.secondary,
                    ),
                    const Divider(height: 16, color: AppColors.outlineVariant),
                    _financialRow(
                      'Net Payable by Homeowner',
                      '₹${_formatCurrency(financials.netPayableCost)}',
                      isBold: true,
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 6),
                    _financialRow(
                      'Annual Electricity Bill Savings',
                      '₹${_formatCurrency(financials.annualSavings)} / yr',
                      valueColor: AppColors.secondary,
                    ),
                    _financialRow(
                      'Estimated Payback Period',
                      '${financials.paybackPeriodYears.toStringAsFixed(1)} Years',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),

              // ── 4. Selected Verified EPC Partner ─────────────────────────
              if (installer != null)
                _buildConnectedInstallerCard(context, installer)
              else
                _buildEmptyInstallerCard(context),
              const SizedBox(height: AppSpacing.spaceMd),

              // ── 5. 5-Stage Project Milestone Timeline ────────────────────
              _buildMilestoneOverviewCard(context, capacity, installer),
              const SizedBox(height: AppSpacing.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedInstallerCard(
    BuildContext context,
    VerifiedInstaller installer,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connected EPC Partner',
                style: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                  borderRadius: AppRadii.full,
                ),
                child: Text(
                  installer.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.engineering_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      installer.name,
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${installer.rating}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' (${installer.reviewsCount} reviews) · ${installer.distanceKm} km',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Modules: ${installer.primaryBrand} · Inverter: ${installer.inverterBrand}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: installer.badges.map((b) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  b,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${installer.phone}...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadii.cardSm,
                    ),
                  ),
                  icon: const Icon(
                    Icons.phone_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Call Partner',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton.secondary(
                  label: 'Switch Partner',
                  icon: Icons.swap_horiz_rounded,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.nearbyInstallers);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInstallerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.engineering_outlined,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No EPC Partner Connected Yet',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Connect with an empanelled contractor for site audit & DISCOM filing.',
                      style: TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton.primary(
            label: 'Connect with Verifier / Installer',
            icon: Icons.handshake_rounded,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.nearbyInstallers);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneOverviewCard(
    BuildContext context,
    String capacity,
    VerifiedInstaller? installer,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5-Stage Execution Timeline',
                style: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Stage 2 of 5',
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 11,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _milestoneItem(
            '1. Solar Feasibility Audit',
            'Completed ($capacity kW system sized)',
            isDone: true,
          ),
          _milestoneItem(
            '2. Physical Site Verification',
            installer != null
                ? 'Scheduled with ${installer.name}'
                : 'Pending partner assignment',
            isDone: installer != null,
            isCurrent: installer == null,
          ),
          _milestoneItem(
            '3. DISCOM Net-Metering Filing',
            'BESCOM application & grid sync permit',
            isDone: false,
          ),
          _milestoneItem(
            '4. Rooftop Hardware Mounting',
            'Panels, inverters & lightning arrestors',
            isDone: false,
          ),
          _milestoneItem(
            '5. Commissioning & Subsidy Credit',
            'Bi-directional meter installation & ₹78K DBT',
            isDone: false,
            isLast: true,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.installationTimeline);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: AppRadii.full),
              ),
              icon: const Icon(
                Icons.timeline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              label: Text(
                'View Detailed 5-Stage Timeline',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _milestoneItem(
    String title,
    String desc, {
    bool isDone = false,
    bool isCurrent = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : (isCurrent
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded),
            size: 18,
            color: isDone
                ? AppColors.secondary
                : (isCurrent ? AppColors.primary : AppColors.outlineVariant),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isDone || isCurrent
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isDone || isCurrent
                        ? AppColors.onSurface
                        : AppColors.outline,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specBox({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.cardSm,
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
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
                  title,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.labelLg.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 15,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.outline,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _financialRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
