/// Model representing turnkey costs, PM Surya Ghar subsidy, and bill savings.
class FinancialBreakdown {
  final double grossTurnkeyCost;
  final double centralDbtSubsidy;
  final double netPayableCost;
  final double baselineMonthlyBill;
  final double projectedMonthlyBill;
  final double monthlySavings;
  final double annualSavings;
  final double paybackPeriodYears;
  final double cumulative25YearSavings;

  const FinancialBreakdown({
    required this.grossTurnkeyCost,
    required this.centralDbtSubsidy,
    required this.netPayableCost,
    required this.baselineMonthlyBill,
    required this.projectedMonthlyBill,
    required this.monthlySavings,
    required this.annualSavings,
    required this.paybackPeriodYears,
    required this.cumulative25YearSavings,
  });

  factory FinancialBreakdown.mockStandard() {
    return const FinancialBreakdown(
      grossTurnkeyCost: 340000.0,
      centralDbtSubsidy: 78000.0,
      netPayableCost: 262000.0,
      baselineMonthlyBill: 3850.0,
      projectedMonthlyBill: 500.0,
      monthlySavings: 3350.0,
      annualSavings: 40200.0,
      paybackPeriodYears: 3.2,
      cumulative25YearSavings: 980000.0,
    );
  }
}
