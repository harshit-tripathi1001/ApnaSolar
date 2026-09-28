import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/auth_service.dart';
import '../../services/pdf_report_service.dart';
import '../../services/solar_session_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

/// Solar Report Screen (Stitch: 547ed46925cc4a00bf224ff0c2c0ec81)
///
/// Displays the official solar audit summary with real-time PDF generation
/// and direct navigation into the Home Dashboard.
class SolarReportScreen extends StatefulWidget {
  const SolarReportScreen({super.key});

  @override
  State<SolarReportScreen> createState() => _SolarReportScreenState();
}

class _SolarReportScreenState extends State<SolarReportScreen> {
  bool _isGeneratingPdf = false;

  Future<void> _handleDownloadPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await PdfReportService().downloadOrPrintReport(
        context: context,
        session: SolarSessionState(),
        user: AuthService().currentUser,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not generate PDF: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _handleOpenDashboard() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SolarSessionState();
    final prop = session.selectedProperty;
    final financials = session.financialBreakdown;
    final solar = session.solarEstimate;
    final capacity = session.selectedCapacityKw.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        title: Text(
          'Official Solar Audit Report',
          style: AppTypography.headlineSm.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Download as PDF',
            icon: const Icon(
              Icons.download_rounded,
              color: AppColors.secondary,
            ),
            onPressed: _isGeneratingPdf ? null : _handleDownloadPdf,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Certification Badge ──────────────────────────────
              AppCard(
                color: AppColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: AppRadii.full,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 13,
                                color: AppColors.onSecondaryFixed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PM SURYA GHAR COMPLIANT',
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.onSecondaryFixed,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'AUDIT DOSSIER',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.primaryFixed,
                            letterSpacing: 0.8,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$capacity kW Rooftop Feasibility Audit',
                      style: AppTypography.headlineMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      prop.formattedAddress,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.primaryFixed,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceMd),

              // ── 4 Key Diagnostic Highlights ──────────────────────────────
              Row(
                children: [
                  _metricTile(
                    title: 'System Size',
                    value: '$capacity kW',
                    unit: '14 Bifacial Panels',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  _metricTile(
                    title: 'Central Subsidy',
                    value: '₹78,000',
                    unit: 'Direct DBT Credit',
                    color: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Row(
                children: [
                  _metricTile(
                    title: 'Annual Savings',
                    value: '₹${financials.annualSavings.toInt()}',
                    unit: 'per year in bank',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  _metricTile(
                    title: 'Payback Period',
                    value:
                        '${financials.paybackPeriodYears.toStringAsFixed(1)} Yrs',
                    unit: '25-Yr ROI: ₹14.2L',
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMd),

              // ── Rooftop & Environmental Specifications ───────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Technical & Environmental Summary',
                      style: AppTypography.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _specRow(
                      'Total Measured Terrace',
                      '${session.rooftopAnalysis.totalGrossAreaSqFt.toInt()} sq. ft.',
                    ),
                    _specRow(
                      'Effective Usable Solar Area',
                      '${session.rooftopAnalysis.netUsableAreaSqFt.toInt()} sq. ft.',
                    ),
                    _specRow('Obstacles Excluded', 'Mumty & Sintex water tank'),
                    _specRow(
                      'Estimated Annual Generation',
                      '~${solar.annualGenerationKwh.toInt()} kWh / year',
                    ),
                    _specRow(
                      'Lifetime CO₂ Offset',
                      '~${solar.co2OffsetTonnesPerYear.toStringAsFixed(1)} Tonnes / year',
                    ),
                    _specRow(
                      'Lifetime Tree Equivalent',
                      '${solar.treeOffsetEquivalent} trees planted',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),

              // ── Primary Action: Download as PDF ──────────────────────────
              AppButton(
                label: _isGeneratingPdf
                    ? 'Generating PDF...'
                    : 'Download as PDF Report',
                subtitle: 'Official signed feasibility dossier',
                trailingIcon: Icons.download_rounded,
                isLoading: _isGeneratingPdf,
                onPressed: _handleDownloadPdf,
              ),
              const SizedBox(height: AppSpacing.spaceSm),

              // ── Secondary Action: Open Dashboard ─────────────────────────
              OutlinedButton.icon(
                onPressed: _handleOpenDashboard,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.full),
                ),
                icon: const Icon(
                  Icons.dashboard_rounded,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Complete & Open Home Dashboard',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spaceLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile({
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spaceSm + 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: AppRadii.cardSm,
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowTinted,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Text(
              unit,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.outline,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
