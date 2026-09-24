/// Model representing calculated solar PV generation, equipment, and capacity.
class SolarEstimate {
  final double capacityKw;
  final int panelCount;
  final int panelWattage;
  final String panelType;
  final double inverterCapacityKw;
  final double dailyGenerationKwh;
  final double monthlyGenerationKwh;
  final double annualGenerationKwh;
  final int treeOffsetEquivalent;
  final double co2OffsetTonnesPerYear;

  const SolarEstimate({
    required this.capacityKw,
    required this.panelCount,
    required this.panelWattage,
    required this.panelType,
    required this.inverterCapacityKw,
    required this.dailyGenerationKwh,
    required this.monthlyGenerationKwh,
    required this.annualGenerationKwh,
    required this.treeOffsetEquivalent,
    required this.co2OffsetTonnesPerYear,
  });

  factory SolarEstimate.mockOptimal() {
    return const SolarEstimate(
      capacityKw: 5.8,
      panelCount: 12,
      panelWattage: 550,
      panelType: 'Tier-1 TopCon Bi-facial Monocrystalline',
      inverterCapacityKw: 5.0,
      dailyGenerationKwh: 23.2,
      monthlyGenerationKwh: 696.0,
      annualGenerationKwh: 8352.0,
      treeOffsetEquivalent: 138,
      co2OffsetTonnesPerYear: 6.8,
    );
  }
}
