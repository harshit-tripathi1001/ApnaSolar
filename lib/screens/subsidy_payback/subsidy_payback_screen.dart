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

/// Dynamic, Interactive PM Surya Ghar Subsidy & Payback Screen
/// Shows DBT eligibility, 4-step national portal claim tracker,
/// and interactive 25-year cumulative savings timeline.
class SubsidyPaybackScreen extends StatefulWidget {
  const SubsidyPaybackScreen({super.key});

  @override
  State<SubsidyPaybackScreen> createState() => _SubsidyPaybackScreenState();
}

class _SubsidyPaybackScreenState extends State<SubsidyPaybackScreen> {
  final _session = SolarSessionState();
  int _selectedYearTab = 10; // 5, 10, 15, 20, 25

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

    final subsidy = financials.centralDbtSubsidy;
    final net = financials.netPayableCost;
    final annualSavings = financials.annualSavings;
    final paybackYears = financials.paybackPeriodYears;
    final cumulative25 = financials.cumulative25YearSavings;

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
                    // PM Surya Ghar Hero Card
                    _buildSubsidyHeroCard(capacity, subsidy),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Payback & Breakeven Metric Card
                    _buildBreakevenCard(paybackYears, annualSavings, net),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Interactive Cumulative Savings Tracker
                    _buildCumulativeSavingsTracker(annualSavings, cumulative25),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // 4-Step National Portal Claim Process
                    _buildClaimTrackerCard(),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Environmental Green Dividend
                    _buildGreenDividendCard(estimate),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Subsidy & Payback',
                      style: AppTypography.titleLg.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'PM Surya Ghar Muft Bijli Yojana',
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: AppRadii.full,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 13, color: Color(0xFF2E7D32)),
                const SizedBox(width: 4),
                Text(
                  'MNRE Validated',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubsidyHeroCard(double capacity, double subsidy) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E4D00), Color(0xFFBA6500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.card,
        boxShadow: const [
          BoxShadow(
            color: Color(0x228E4D00),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadii.full,
                ),
                child: const Text(
                  'CENTRAL DBT SUBSIDY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.full,
                ),
                child: const Text(
                  'Direct Bank Transfer',
                  style: TextStyle(
                    color: Color(0xFF8E4D00),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '₹${_formatInr(subsidy)}',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'for ${capacity.toStringAsFixed(1)} kW system',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Credited directly into your Aadhaar-linked savings account within 30 days of bi-directional net-meter sync.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '1 kW: ₹30,000 | 2 kW: ₹60,000 | 3 kW+: ₹78,000 (Max Cap)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakevenCard(
    double paybackYears,
    double annualSavings,
    double net,
  ) {
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
              Expanded(
                child: Text(
                  'Investment Breakeven',
                  style: AppTypography.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: 'High ROI',
                variant: StatusBadgeVariant.green,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.25),
                    borderRadius: AppRadii.cardSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Payback In',
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${paybackYears.toStringAsFixed(1)} Years',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Text(
                        'Zero-cost energy thereafter',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: AppRadii.cardSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annual Savings',
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '₹${_formatInr(annualSavings)}',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      Text(
                        '₹${_formatInr(annualSavings / 12)} / month',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.secondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Visual Progress representation of 25-year panel lifetime
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (paybackYears * 10).round(),
                    child: Container(color: AppColors.secondary),
                  ),
                  Expanded(
                    flex: ((25 - paybackYears) * 10).round(),
                    child: Container(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            children: [
              Text(
                '0 to ${paybackYears.toStringAsFixed(1)} Yrs: Capital Recovery',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(25 - paybackYears).toStringAsFixed(1)} Years: 100% Free Energy',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCumulativeSavingsTracker(
    double annualSavings,
    double cumulative25,
  ) {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 4,
            children: [
              Text(
                '25-Year Cumulative Wealth',
                style: AppTypography.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'Assumes 3% tariff inflation',
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 10,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Year Selector Tabs
          Row(
            children: [5, 10, 15, 20, 25].map((yr) {
              final isSelected = _selectedYearTab == yr;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => setState(() => _selectedYearTab = yr),
                    borderRadius: AppRadii.cardSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceContainerLow,
                        borderRadius: AppRadii.cardSm,
                      ),
                      child: Center(
                        child: Text(
                          '$yr Yrs',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Highlighted selected year savings
          Builder(
            builder: (context) {
              // Factor with 3% annual tariff increase
              double total = 0.0;
              for (int i = 1; i <= _selectedYearTab; i++) {
                total += annualSavings * (1 + 0.03 * i);
              }
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.cardSm,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Savings by Year $_selectedYearTab',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '₹${_formatInr(total)}',
                              style: AppTypography.headlineSm.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(total / 100000).toStringAsFixed(1)} Lakhs',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClaimTrackerCard() {
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
                Icons.account_balance_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'National Portal 4-Step Claim Process',
                  style: AppTypography.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPortalStep(
            '1',
            'Technical Feasibility Approval (TFA)',
            'Vendor applies on DISCOM portal with rooftop specs & consumer ID',
            'Day 1-7',
            true,
          ),
          _buildPortalStep(
            '2',
            'Installation by Empanelled Vendor',
            'Rooftop panels, inverter & ALMM compliant equipment mounted',
            'Day 8-20',
            true,
          ),
          _buildPortalStep(
            '3',
            'Net-Meter Swap & Inspection',
            'DISCOM inspects earth pit, installs bi-directional smart meter',
            'Day 21-25',
            true,
          ),
          _buildPortalStep(
            '4',
            'Direct Benefit Transfer (DBT)',
            'MNRE directly transfers ₹78,000 subsidy into your bank account',
            'Day 30',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildPortalStep(
    String step,
    String title,
    String desc,
    String timeframe,
    bool showDivider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primary,
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (showDivider)
              Container(width: 2, height: 32, color: AppColors.outlineVariant),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.labelMd.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      timeframe,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.bodyMd.copyWith(
                    fontSize: 11,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreenDividendCard(dynamic estimate) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.card,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF2E7D32),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lifetime Environmental Dividend',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Offsets ~${(estimate.co2OffsetTonnesPerYear * 25).toStringAsFixed(1)} tons of CO₂ · Equal to planting ${(estimate.treeOffsetEquivalent * 25)} mature teak trees.',
                  style: AppTypography.bodyMd.copyWith(
                    fontSize: 11,
                    color: AppColors.outline,
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
              Navigator.pushNamed(context, AppRoutes.costBreakdown),
          icon: const Icon(
            Icons.currency_rupee_rounded,
            color: AppColors.primary,
          ),
          label: const Text('View Detailed Cost & EMI Breakdown'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.cardSm),
          ),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.quotationAnalysis),
          icon: const Icon(
            Icons.request_quote_rounded,
            color: AppColors.secondary,
          ),
          label: const Text('View Turnkey Quotation BOM Dossier'),
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
        label: 'Connect with Verified Local Installers',
        icon: Icons.people_outline,
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.nearbyInstallers),
      ),
    );
  }
}
