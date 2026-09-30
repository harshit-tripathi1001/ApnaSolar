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

/// Dynamic, Interactive Simple & Honest Pricing Screen
/// Allows homeowners to slide system capacity, view itemized bill of materials,
/// calculate green loan EMIs, and understand transparent payment milestones.
class CostBreakdownScreen extends StatefulWidget {
  const CostBreakdownScreen({super.key});

  @override
  State<CostBreakdownScreen> createState() => _CostBreakdownScreenState();
}

class _CostBreakdownScreenState extends State<CostBreakdownScreen> {
  final _session = SolarSessionState();

  late double _capacityKw;
  int _selectedTenureMonths = 36;
  bool _includeZeroDownPayment = false;

  @override
  void initState() {
    super.initState();
    _capacityKw = _session.selectedCapacityKw.clamp(2.0, 10.0);
  }

  // Formatting helper
  String _formatInr(num amount) {
    return amount.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic recalculation on the fly based on selected capacity
    final financials = SolarCalculatorService.calculateFinancials(
      capacityKw: _capacityKw,
      currentMonthlyBill: _session.monthlyBill,
    );

    final gross = financials.grossTurnkeyCost;
    final subsidy = financials.centralDbtSubsidy;
    final net = financials.netPayableCost;

    // Component splits
    final panelsCost = gross * 0.48;
    final inverterCost = gross * 0.22;
    final structureCost = gross * 0.15;
    final bosCost = gross * 0.08;
    final netMeteringCost = gross * 0.07;

    // EMI calculation (SBI Green Solar Loan at 7.0% p.a.)
    final principal = _includeZeroDownPayment ? net : net * 0.80;
    const annualInterestRate = 0.07;
    final monthlyRate = annualInterestRate / 12;
    final n = _selectedTenureMonths;
    // Standard EMI formula: P * r * (1 + r)^n / ((1 + r)^n - 1)
    final num factor = (1 + monthlyRate);
    final num factorN = List.filled(n, factor).fold(1.0, (a, b) => a * b);
    final emi = (principal * monthlyRate * factorN) / (factorN - 1);
    final monthlySavings = financials.annualSavings / 12;

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
                    // System Capacity Slider Card
                    _buildCapacitySelectorCard(),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Hero Net Price Bento Card
                    _buildHeroPricingCard(gross, subsidy, net),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Itemized Component Cost Breakdown
                    _buildItemizedBreakdown(
                      panelsCost: panelsCost,
                      inverterCost: inverterCost,
                      structureCost: structureCost,
                      bosCost: bosCost,
                      netMeteringCost: netMeteringCost,
                      total: gross,
                    ),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Dynamic Green Loan EMI Calculator
                    _buildEmiCalculator(emi, monthlySavings, principal),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Transparent Payment Milestones Card
                    _buildMilestonesCard(net),
                    const SizedBox(height: AppSpacing.spaceMd),

                    // Quick Jump Pills
                    _buildQuickActionPills(context),
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
          Flexible(
            child: Column(
              children: [
                Text(
                  'Simple, Honest Pricing',
                  style: AppTypography.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _session.selectedProperty.locality,
                  style: AppTypography.bodyMd.copyWith(
                    fontSize: 11,
                    color: AppColors.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: AppRadii.full,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Zero Hidden Fees',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySelectorCard() {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Capacity (kWp)',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          '${_capacityKw.toStringAsFixed(1)} kW',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        StatusBadge(
                          label: 'Recommended',
                          variant: StatusBadgeVariant.green,
                          fontSize: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.solar_power_rounded,
                  color: AppColors.secondary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondary,
              inactiveTrackColor: AppColors.surfaceContainerHighest,
              thumbColor: AppColors.primary,
              trackHeight: 4,
            ),
            child: Slider(
              value: _capacityKw,
              min: 2.0,
              max: 10.0,
              divisions: 16,
              onChanged: (val) {
                setState(() => _capacityKw = val);
                _session.setSelectedCapacity(val);
              },
            ),
          ),

          // Quick Capacity Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [2.0, 3.0, 4.0, 5.0, 6.0, 8.0, 10.0].map((kw) {
                final isSelected = (_capacityKw - kw).abs() < 0.1;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${kw.toInt()} kW'),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.surfaceContainerLow,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _capacityKw = kw);
                        _session.setSelectedCapacity(kw);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPricingCard(double gross, double subsidy, double net) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.card,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F003822),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'TOTAL NET PAYABLE',
                  style: AppTypography.labelMd.copyWith(
                    color: Colors.white70,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadii.full,
                ),
                child: const Text(
                  'Turnkey EPC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            children: [
              Text(
                '₹${_formatInr(net)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'All-inclusive',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gross Cost',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${_formatInr(gross)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 26, width: 1, color: Colors.white24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'DBT Subsidy',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.verified,
                            size: 11,
                            color: Color(0xFFFFD54F),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '- ₹${_formatInr(subsidy)}',
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 26, width: 1, color: Colors.white24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Cost / Watt',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${(net / (_capacityKw * 1000)).toStringAsFixed(1)}/W',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  Widget _buildItemizedBreakdown({
    required double panelsCost,
    required double inverterCost,
    required double structureCost,
    required double bosCost,
    required double netMeteringCost,
    required double total,
  }) {
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
              Flexible(
                child: Text(
                  'Itemized Component Split',
                  style: AppTypography.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Turnkey BOM',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.outline,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Colored visual bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: 48,
                    child: Container(color: AppColors.primary),
                  ),
                  Expanded(
                    flex: 22,
                    child: Container(color: AppColors.secondary),
                  ),
                  Expanded(
                    flex: 15,
                    child: Container(color: const Color(0xFF00796B)),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(color: const Color(0xFFF57C00)),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(color: const Color(0xFF5E35B1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          _buildComponentRow(
            dotColor: AppColors.primary,
            title: 'Mono-PERC Bifacial PV Panels (48%)',
            specs:
                'Tata Power / Waaree · 550Wp TopCon · 25-Yr Performance Warranty',
            amount: panelsCost,
          ),
          const Divider(height: 18),
          _buildComponentRow(
            dotColor: AppColors.secondary,
            title: 'Grid-Tie Inverter & Smart Wi-Fi Dongle (22%)',
            specs:
                'Growatt / Sungrow · Dual MPPT · Real-time cloud sync · 10-Yr Warranty',
            amount: inverterCost,
          ),
          const Divider(height: 18),
          _buildComponentRow(
            dotColor: const Color(0xFF00796B),
            title: 'HDG Mounting Structure & Walkways (15%)',
            specs:
                'Hot Dip Galvanized 80-micron · 150 km/h wind rated · Elevated tilt',
            amount: structureCost,
          ),
          const Divider(height: 18),
          _buildComponentRow(
            dotColor: const Color(0xFFF57C00),
            title: 'BOS, AC/DC Protections & Earthing (8%)',
            specs:
                'Havells/Polycab copper cables, SPD, MC4 connectors, chemical earthing',
            amount: bosCost,
          ),
          const Divider(height: 18),
          _buildComponentRow(
            dotColor: const Color(0xFF5E35B1),
            title: 'DISCOM Net Meter & CEIG Liaison (7%)',
            specs:
                'Bi-directional meter calibration, testing & commissioning approvals',
            amount: netMeteringCost,
          ),
        ],
      ),
    );
  }

  Widget _buildComponentRow({
    required Color dotColor,
    required String title,
    required String specs,
    required double amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
                  color: AppColors.onSurface,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                specs,
                style: AppTypography.bodyMd.copyWith(
                  fontSize: 11,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '₹${_formatInr(amount)}',
          style: AppTypography.labelMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmiCalculator(
    double emi,
    double monthlySavings,
    double loanAmount,
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
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Green Solar Loan EMI',
                        style: AppTypography.titleLg.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: AppRadii.full,
                ),
                child: const Text(
                  '7.0% p.a. Concession',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Loan tenure chips
          Row(
            children: [12, 24, 36, 60].map((months) {
              final isSelected = _selectedTenureMonths == months;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTenureMonths = months),
                    borderRadius: AppRadii.cardSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceContainerLow,
                        borderRadius: AppRadii.cardSm,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$months M',
                          style: TextStyle(
                            fontSize: 12,
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

          // Zero Down Payment Switch
          Row(
            children: [
              Expanded(
                child: Text(
                  '0% Down Payment (100% Financed)',
                  style: AppTypography.bodyMd.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: _includeZeroDownPayment,
                activeThumbColor: AppColors.primary,
                onChanged: (val) =>
                    setState(() => _includeZeroDownPayment = val),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // EMI vs Savings Comparison Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.25),
              borderRadius: AppRadii.cardSm,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly EMI Outflow',
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
                          '₹${_formatInr(emi)} /mo',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: AppColors.outlineVariant,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avg Monthly Bill Savings',
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
                          '₹${_formatInr(monthlySavings)} /mo',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              monthlySavings >= emi
                  ? '🎉 Your monthly electricity savings pay off the entire loan EMI!'
                  : 'Net effective monthly payment: ₹${_formatInr((emi - monthlySavings).clamp(0, double.infinity))}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: monthlySavings >= emi
                    ? AppColors.primary
                    : AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesCard(double net) {
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
                Icons.account_tree_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Transparent Tranche Milestones',
                  style: AppTypography.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMilestoneStep(
            '1',
            '10% Advance',
            'Site audit & DISCOM net-meter feasibility',
            net * 0.10,
          ),
          _buildMilestoneStep(
            '2',
            '40% Material Dispatch',
            'Panels, inverters & structure arrive on site',
            net * 0.40,
          ),
          _buildMilestoneStep(
            '3',
            '40% Installation',
            'Mechanical & electrical commissioning complete',
            net * 0.40,
          ),
          _buildMilestoneStep(
            '4',
            '10% Synchronization',
            'Bi-directional meter installed & sync active',
            net * 0.10,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneStep(
    String step,
    String title,
    String desc,
    double amount,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.secondaryContainer,
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
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
                  desc,
                  style: AppTypography.bodyMd.copyWith(
                    fontSize: 10,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${_formatInr(amount)}',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionPills(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.cardSm),
          ),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.subsidyPayback),
          icon: const Icon(Icons.savings_rounded, color: AppColors.secondary),
          label: const Text('PM Surya Ghar Subsidy & Payback Timeline'),
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
            color: AppColors.primary,
          ),
          label: const Text('Turnkey EPC Official Quotation Dossier'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: AppRadii.cardSm),
          ),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.nearbyInstallers),
          icon: const Icon(Icons.people_outline, color: AppColors.onSurface),
          label: const Text('Connect with Verified Local Installers (8)'),
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
        label: 'Generate Official Audit Report (PDF)',
        icon: Icons.picture_as_pdf_rounded,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.solarReport),
      ),
    );
  }
}
