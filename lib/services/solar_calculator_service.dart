import '../models/financial_breakdown.dart';
import '../models/rooftop_analysis.dart';
import '../models/solar_estimate.dart';

/// Calculation engine for solar rooftop estimation and PM Surya Ghar subsidies.
class SolarCalculatorService {
  /// Standard central PM Surya Ghar DBT subsidy calculation:
  /// - ₹30,000 / kW for the first 2 kW
  /// - ₹18,000 for the 3rd kW
  /// - Max subsidy capped at ₹78,000 for 3 kW and above.
  static double calculateSubsidy(double capacityKw) {
    if (capacityKw <= 0) return 0.0;
    if (capacityKw <= 1.0) return 30000.0;
    if (capacityKw <= 2.0) return 60000.0;
    return 78000.0; // Max cap under PM Surya Ghar Yojana
  }

  /// Calculates turnkey installation costs based on standard Indian benchmark rates (~₹58,000 - ₹62,000 / kW)
  static double calculateGrossCost(double capacityKw) {
    return (capacityKw * 58620.0).roundToDouble();
  }

  /// Estimates solar PV generation based on peak sun hours (~4.0 - 5.2 hrs/day in India)
  static SolarEstimate calculateEstimate({
    required double capacityKw,
    double peakSunHours = 5.2,
  }) {
    final dailyKwh =
        capacityKw * peakSunHours * 0.78; // 78% PR (Performance Ratio)
    final monthlyKwh = dailyKwh * 30.0;
    final annualKwh = dailyKwh * 365.0;
    final panelCount = (capacityKw * 1000 / 550).ceil();
    final treeEquivalent = (annualKwh * 0.0165).round();
    final co2Offset = double.parse((annualKwh * 0.00082).toStringAsFixed(1));

    return SolarEstimate(
      capacityKw: capacityKw,
      panelCount: panelCount,
      panelWattage: 550,
      panelType: 'Tier-1 TopCon Bi-facial Monocrystalline',
      inverterCapacityKw: capacityKw > 5.0 ? 5.0 : capacityKw,
      dailyGenerationKwh: double.parse(dailyKwh.toStringAsFixed(1)),
      monthlyGenerationKwh: double.parse(monthlyKwh.toStringAsFixed(1)),
      annualGenerationKwh: double.parse(annualKwh.toStringAsFixed(0)),
      treeOffsetEquivalent: treeEquivalent,
      co2OffsetTonnesPerYear: co2Offset,
    );
  }

  /// Calculates financial savings and payback period
  static FinancialBreakdown calculateFinancials({
    required double capacityKw,
    double currentMonthlyBill = 3850.0,
    double electricityTariffPerKwh = 7.5,
  }) {
    final gross = calculateGrossCost(capacityKw);
    final subsidy = calculateSubsidy(capacityKw);
    final net = gross - subsidy;

    // Monthly units generated
    final monthlyUnits = capacityKw * 5.2 * 30.0 * 0.78;
    final grossSavings = monthlyUnits * electricityTariffPerKwh;
    final maxBillSavings = currentMonthlyBill - 500.0;
    final monthlySavings = grossSavings > maxBillSavings
        ? maxBillSavings
        : grossSavings;
    final projectedBill = (currentMonthlyBill - monthlySavings).clamp(
      500.0,
      double.infinity,
    );
    final annualSavings = monthlySavings * 12.0;
    final paybackYears = double.parse((net / annualSavings).toStringAsFixed(1));
    final cumulative25Yr = annualSavings * 25.0 * 0.95; // 5% degradation buffer

    return FinancialBreakdown(
      grossTurnkeyCost: gross,
      centralDbtSubsidy: subsidy,
      netPayableCost: net,
      baselineMonthlyBill: currentMonthlyBill,
      projectedMonthlyBill: projectedBill,
      monthlySavings: double.parse(monthlySavings.toStringAsFixed(0)),
      annualSavings: double.parse(annualSavings.toStringAsFixed(0)),
      paybackPeriodYears: paybackYears,
      cumulative25YearSavings: double.parse(cumulative25Yr.toStringAsFixed(0)),
    );
  }

  /// Determines recommended capacity from usable rooftop area
  /// 1 kW approximately requires 80 - 100 sq ft shadow-free area
  static double recommendCapacityFromArea(RooftopAnalysis analysis) {
    final maxByArea = analysis.netUsableAreaSqFt / 95.0;
    // Step by 0.5 kW intervals
    final rounded = (maxByArea * 2).floor() / 2.0;
    return rounded.clamp(3.0, 10.0);
  }
}
