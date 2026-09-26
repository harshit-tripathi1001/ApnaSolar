import 'package:flutter/foundation.dart';

import '../models/financial_breakdown.dart';
import '../models/property_location.dart';
import '../models/rooftop_analysis.dart';
import '../models/solar_estimate.dart';
import 'solar_calculator_service.dart';

/// Central singleton and ChangeNotifier maintaining prototype session state.
/// Preserves selected property, rooftop geometry, customized capacity, and financial model
/// across navigation and app restarts.
class SolarSessionState extends ChangeNotifier {
  static final SolarSessionState _instance = SolarSessionState._internal();
  factory SolarSessionState() => _instance;

  SolarSessionState._internal() {
    _resetToDefaults();
  }

  late PropertyLocation _selectedProperty;
  late String _propertyType;
  late String _roofType;
  late double _monthlyBill;
  late double _sanctionedLoadKw;
  late RooftopAnalysis _rooftopAnalysis;
  late double _selectedCapacityKw;
  late SolarEstimate _solarEstimate;
  late FinancialBreakdown _financialBreakdown;

  // Getters
  PropertyLocation get selectedProperty => _selectedProperty;
  String get propertyType => _propertyType;
  String get roofType => _roofType;
  double get monthlyBill => _monthlyBill;
  double get sanctionedLoadKw => _sanctionedLoadKw;
  RooftopAnalysis get rooftopAnalysis => _rooftopAnalysis;
  double get selectedCapacityKw => _selectedCapacityKw;
  SolarEstimate get solarEstimate => _solarEstimate;
  FinancialBreakdown get financialBreakdown => _financialBreakdown;

  void _resetToDefaults() {
    _selectedProperty = PropertyLocation.mockIndiranagar();
    _propertyType = 'Independent House / Villa';
    _roofType = 'Flat Concrete Terrace (RCC)';
    _monthlyBill = 3850.0;
    _sanctionedLoadKw = 5.0;
    _rooftopAnalysis = RooftopAnalysis.mockIndiranagarTerrace();
    _selectedCapacityKw = SolarCalculatorService.recommendCapacityFromArea(_rooftopAnalysis);
    _recalculateDerived();
  }

  void _recalculateDerived() {
    _solarEstimate = SolarCalculatorService.calculateEstimate(
      capacityKw: _selectedCapacityKw,
      peakSunHours: _selectedProperty.peakSunHoursPerDay,
    );
    _financialBreakdown = SolarCalculatorService.calculateFinancials(
      capacityKw: _selectedCapacityKw,
      currentMonthlyBill: _monthlyBill,
    );
  }

  /// Updates the selected property location (from GPS or search)
  void setProperty(PropertyLocation property) {
    _selectedProperty = property;
    _recalculateDerived();
    notifyListeners();
  }

  /// Updates property characteristics
  void updatePropertyDetails({
    String? propertyType,
    String? roofType,
    double? monthlyBill,
    double? sanctionedLoadKw,
  }) {
    if (propertyType != null) _propertyType = propertyType;
    if (roofType != null) _roofType = roofType;
    if (monthlyBill != null) _monthlyBill = monthlyBill;
    if (sanctionedLoadKw != null) _sanctionedLoadKw = sanctionedLoadKw;

    _recalculateDerived();
    notifyListeners();
  }

  /// Updates rooftop measurement after boundary drawing or AI scan
  void updateRooftopAnalysis({
    required double grossAreaSqFt,
    required double usableAreaSqFt,
    double? obstacleAreaSqFt,
    double? viabilityPercent,
    int? obstacleCount,
    double? slopeDegrees,
    String? orientation,
    double? irradianceKwhPerM2,
  }) {
    final obstacle = obstacleAreaSqFt ?? (grossAreaSqFt - usableAreaSqFt).clamp(0.0, double.infinity);
    final viability = viabilityPercent ?? (grossAreaSqFt > 0 ? (usableAreaSqFt / grossAreaSqFt * 100).roundToDouble() : 78.0);

    _rooftopAnalysis = RooftopAnalysis(
      totalGrossAreaSqFt: grossAreaSqFt,
      netUsableAreaSqFt: usableAreaSqFt,
      obstacleAreaSqFt: obstacle,
      solarViabilityPercent: viability,
      obstacleCount: obstacleCount ?? 2,
      slopeDegrees: slopeDegrees ?? 0.0,
      orientation: orientation ?? '180° South',
      irradianceKwhPerM2: irradianceKwhPerM2 ?? 5.4,
    );

    _selectedCapacityKw = SolarCalculatorService.recommendCapacityFromArea(_rooftopAnalysis);
    _recalculateDerived();
    notifyListeners();
  }

  /// Updates selected capacity from slider or customizer
  void setSelectedCapacity(double capacityKw) {
    _selectedCapacityKw = capacityKw;
    _recalculateDerived();
    notifyListeners();
  }

  /// Resets state back to clean initial state
  void reset() {
    _resetToDefaults();
    notifyListeners();
  }
}
