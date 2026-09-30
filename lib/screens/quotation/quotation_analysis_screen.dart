import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/solar_calculator_service.dart';
import '../../services/solar_session_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/status_badge.dart';

/// Dynamic, Interactive Official Quotation & Financial Analysis Dossier Screen
/// Features turnkey Bill of Materials (BOM), Levelized Cost of Electricity (LCOE),
/// Internal Rate of Return (IRR), and warranty guarantees.
class QuotationAnalysisScreen extends StatefulWidget {
  const QuotationAnalysisScreen({super.key});

  @override
  State<QuotationAnalysisScreen> createState() =>
      _QuotationAnalysisScreenState();
}

class _QuotationAnalysisScreenState extends State<QuotationAnalysisScreen> {
  final _session = SolarSessionState();

  String _formatInr(num amount) {
    return amount.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final capacity = _session.selectedCapacityKw;
    final financials = SolarCalculatorService.calculateFinancials(
      capacityKw: capacity,
      currentMonthlyBill: _session.monthlyBill,
    );
    final estimate = _session.solarEstimate;
    final property = _session.selectedProperty;

    final gross = financials.grossTurnkeyCost;
    final subsidy = financials.centralDbtSubsidy;
    final net = financials.netPayableCost;
    final annualSavings = financials.annualSavings;
    final payback = financials.paybackPeriodYears;

    // Financial KPI calculations
    // LCOE = Total Net Lifecycle Cost / 25-Year Generation
    final totalGen25Years =
        estimate.annualGenerationKwh * 25 * 0.95; // 0.5%/yr degradation
    final lcoe = totalGen25Years > 0 ? (net / totalGen25Years) : 2.12;
    // Estimated IRR: Annual Savings / Net Cost
    final irr = net > 0
        ? ((annualSavings / net) * 100).clamp(18.0, 34.0)
        : 26.5;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.margin,
                  vertical: AppSpacing.spaceSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Official Dossier Header Card
                    _buildDossierHeader(property, capacity),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Executive Financial KPI Highlights (LCOE, IRR, Payback)
                    _buildExecutiveKpiCard(net, lcoe, irr, payback),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Itemized Bill of Materials (BOM)
                    _buildBomTable(gross, subsidy, net),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Comprehensive Warranties & SLA Guarantees
                    _buildWarrantyDossier(),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // DISCOM Net-Metering Compliance Check
                    _buildComplianceCard(),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Quick Jump Actions
                    _buildQuickActions(context),
                    const SizedBox(height: AppSpacing.spaceLg),
                  ],
                ),
              ),
            ),
            _buildBottomCta(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: AppRadii.full,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Quotation & Analysis',
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Ref: AS-2026-BLR-0842',
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 11,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: AppRadii.full,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_clock_outlined,
                  size: 13,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Valid 15 Days',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDossierHeader(dynamic property, double capacity) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROPOSED SOLAR PLANT',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.outline,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${capacity.toStringAsFixed(1)} kWp Grid-Tied System',
                    style: AppTypography.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: 'ALMM Approved',
                variant: StatusBadgeVariant.green,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Site Location',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 10,
                        color: AppColors.outline,
                      ),
                    ),
                    Text(
                      '${property.locality}, ${property.pincode}',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected DISCOM',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 10,
                        color: AppColors.outline,
                      ),
                    ),
                    Text(
                      'BESCOM · LT-2 Tariff',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rooftop Area',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 10,
                        color: AppColors.outline,
                      ),
                    ),
                    Text(
                      '${_session.rooftopAnalysis.netUsableAreaSqFt.toInt()} sq ft',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveKpiCard(
    double net,
    double lcoe,
    double irr,
    double payback,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.25),
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Financial Performance Scorecard',
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.trending_up_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiPill(
                  'LCOE (Cost/Unit)',
                  '₹${lcoe.toStringAsFixed(2)}',
                  'vs ₹8.50 Grid',
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiPill(
                  'Equity IRR',
                  '${irr.toStringAsFixed(1)}%',
                  'Tax-Free Returns',
                  const Color(0xFF00796B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildKpiPill(
                  'Payback Period',
                  '${payback.toStringAsFixed(1)} Yrs',
                  'Full Net Amortization',
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiPill(
    String label,
    String value,
    String subtext,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.cardSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 9,
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBomTable(double gross, double subsidy, double net) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Itemized Bill of Materials (BOM)',
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'GST & Subsidy Deducted',
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 10,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildBomRow(
            '1',
            'Solar Modules',
            'Tata/Waaree 550Wp Mono PERC (TopCon)',
            gross * 0.48,
          ),
          const Divider(height: 14),
          _buildBomRow(
            '2',
            'Solar Inverter',
            'Growatt/Sungrow Grid-Tie with Wi-Fi Logger',
            gross * 0.22,
          ),
          const Divider(height: 14),
          _buildBomRow(
            '3',
            'Mounting Superstructure',
            '80μm Hot-Dip Galvanized (Wind 150 km/h)',
            gross * 0.15,
          ),
          const Divider(height: 14),
          _buildBomRow(
            '4',
            'Electrical Balance of System',
            'Havells AC/DC DB, Type-II SPD, Earthing pits',
            gross * 0.08,
          ),
          const Divider(height: 14),
          _buildBomRow(
            '5',
            'Net Meter & CEIG Approvals',
            'Liaisoning, bi-directional meter test & sync',
            gross * 0.07,
          ),
          const SizedBox(height: 14),

          // Total summary block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadii.cardSm,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gross Turnkey Price (Incl. GST)',
                      style: AppTypography.bodyMd.copyWith(fontSize: 12),
                    ),
                    Text(
                      '₹${_formatInr(gross)}',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Less: PM Surya Ghar DBT Subsidy',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      '- ₹${_formatInr(subsidy)}',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FINAL NET OUTFLOW',
                      style: AppTypography.titleLg.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${_formatInr(net)}',
                      style: AppTypography.titleLg.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBomRow(String num, String name, String spec, double cost) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor: AppColors.surfaceContainerHighest,
          child: Text(
            num,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                spec,
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 10.5,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
        Text(
          '₹${_formatInr(cost)}',
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWarrantyDossier() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.security_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Standard Warranties & Guarantees',
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWarrantyItem(
            Icons.solar_power_outlined,
            '25 Years Linear Panel Degradation',
            'Guaranteed >84.8% power output at Year 25 by tier-1 manufacturer.',
          ),
          const SizedBox(height: 8),
          _buildWarrantyItem(
            Icons.electric_bolt_outlined,
            '10 Years Inverter Replacement',
            'Full unit swap warranty against internal component failures.',
          ),
          const SizedBox(height: 8),
          _buildWarrantyItem(
            Icons.handyman_outlined,
            '5 Years Free On-Site O&M Service',
            'Includes semi-annual string health checks & panel de-soiling visits.',
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 10.5,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: AppRadii.card,
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF2E7D32),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '100% MNRE & DISCOM Empanelled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                Text(
                  'All proposed components meet ALMM (Approved List of Module Manufacturers) guidelines required for central subsidy disbursement.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.cardSm),
          ),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.compareVendors),
          icon: const Icon(
            Icons.compare_arrows_rounded,
            color: AppColors.primary,
          ),
          label: const Text('Compare Quotes from 3 Local Vendors'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.cardSm),
          ),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.subsidyPayback),
          icon: const Icon(Icons.savings_rounded, color: AppColors.secondary),
          label: const Text('View PM Surya Ghar Subsidy Breakdown'),
        ),
      ],
    );
  }

  Widget _buildBottomCta(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: 12,
      ),
      child: AppButton.primary(
        label: 'Download Full Quotation PDF Dossier',
        icon: Icons.picture_as_pdf_rounded,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.solarReport),
      ),
    );
  }
}
