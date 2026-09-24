/// Model representing rooftop detection, usable area, and obstacle exclusion.
class RooftopAnalysis {
  final double totalGrossAreaSqFt;
  final double netUsableAreaSqFt;
  final double obstacleAreaSqFt;
  final double solarViabilityPercent;
  final int obstacleCount;
  final double slopeDegrees;
  final String orientation;
  final double irradianceKwhPerM2;

  const RooftopAnalysis({
    required this.totalGrossAreaSqFt,
    required this.netUsableAreaSqFt,
    required this.obstacleAreaSqFt,
    required this.solarViabilityPercent,
    required this.obstacleCount,
    this.slopeDegrees = 0.0,
    this.orientation = '180° South',
    this.irradianceKwhPerM2 = 5.4,
  });

  factory RooftopAnalysis.mockIndiranagarTerrace() {
    return const RooftopAnalysis(
      totalGrossAreaSqFt: 1440.0,
      netUsableAreaSqFt: 1120.0,
      obstacleAreaSqFt: 320.0,
      solarViabilityPercent: 78.0,
      obstacleCount: 2, // Mumty tower + Sintex water tank
      slopeDegrees: 0.0,
      orientation: '180° South',
      irradianceKwhPerM2: 5.4,
    );
  }
}
