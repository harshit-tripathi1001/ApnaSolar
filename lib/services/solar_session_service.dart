import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/financial_breakdown.dart';
import '../models/property_location.dart';
import '../models/rooftop_analysis.dart';
import '../models/solar_estimate.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'solar_calculator_service.dart';

/// Central singleton maintaining the current solar assessment session.
///
/// On startup, attempts to load the most recent analysis from Firestore for
/// the signed-in user. Falls back to sensible defaults when offline or when
/// no saved data exists.
///
/// Persists IDs to [SharedPreferences] so the correct Firestore documents
/// are updated (not duplicated) on the next save.
class SolarSessionState extends ChangeNotifier {
  static final SolarSessionState _instance = SolarSessionState._internal();
  factory SolarSessionState() => _instance;

  SolarSessionState._internal() {
    _resetToDefaults();
  }

  // ─── Firestore IDs ────────────────────────────────────────────────────────

  String? _propertyId;
  String? _rooftopId;
  String? _analysisId;
  String? _rooftopImageUrl;
  String? _rooftopImageStoragePath;

  String? get propertyId => _propertyId;
  String? get rooftopId => _rooftopId;
  String? get analysisId => _analysisId;
  String? get rooftopImageUrl => _rooftopImageUrl;
  String? get rooftopImageStoragePath => _rooftopImageStoragePath;

  // ─── Session data ─────────────────────────────────────────────────────────

  late PropertyLocation _selectedProperty;
  late String _propertyType;
  late String _roofType;
  late double _monthlyBill;
  late double _sanctionedLoadKw;
  late RooftopAnalysis _rooftopAnalysis;
  late double _selectedCapacityKw;
  late SolarEstimate _solarEstimate;
  late FinancialBreakdown _financialBreakdown;

  // ─── Loading state ────────────────────────────────────────────────────────

  bool _isLoadingFromFirestore = false;
  bool _hasLoadedFromFirestore = false;

  bool get isLoadingFromFirestore => _isLoadingFromFirestore;
  bool get hasLoadedFromFirestore => _hasLoadedFromFirestore;

  // ─── Getters ──────────────────────────────────────────────────────────────

  PropertyLocation get selectedProperty => _selectedProperty;
  String get propertyType => _propertyType;
  String get roofType => _roofType;
  double get monthlyBill => _monthlyBill;
  double get sanctionedLoadKw => _sanctionedLoadKw;
  RooftopAnalysis get rooftopAnalysis => _rooftopAnalysis;
  double get selectedCapacityKw => _selectedCapacityKw;
  SolarEstimate get solarEstimate => _solarEstimate;
  FinancialBreakdown get financialBreakdown => _financialBreakdown;

  // ─── Defaults ─────────────────────────────────────────────────────────────

  void _resetToDefaults() {
    _selectedProperty = PropertyLocation.mockIndiranagar();
    _propertyType = 'Independent House / Villa';
    _roofType = 'Flat Concrete Terrace (RCC)';
    _monthlyBill = 3850.0;
    _sanctionedLoadKw = 5.0;
    _rooftopAnalysis = RooftopAnalysis.mockIndiranagarTerrace();
    _selectedCapacityKw = SolarCalculatorService.recommendCapacityFromArea(
      _rooftopAnalysis,
    );
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

  // ─── Firebase load ────────────────────────────────────────────────────────

  /// Loads the most recent analysis from Firestore for the signed-in user.
  ///
  /// Call this once after Firebase initializes and auth state is known.
  Future<void> loadFromFirestore() async {
    final uid = AuthService().uid;
    if (uid == null) return;

    _isLoadingFromFirestore = true;
    notifyListeners();

    try {
      // Restore persisted IDs
      final prefs = await SharedPreferences.getInstance();
      _propertyId = prefs.getString('propertyId_$uid');
      _rooftopId = prefs.getString('rooftopId_$uid');
      _analysisId = prefs.getString('analysisId_$uid');
      _rooftopImageUrl = prefs.getString('rooftopImageUrl_$uid');
      _rooftopImageStoragePath = prefs.getString(
        'rooftopImageStoragePath_$uid',
      );

      final doc = await FirestoreService().getLatestAnalysis(uid);
      if (doc != null) {
        _analysisId = doc['id'] as String?;
        _solarEstimate = FirestoreService.estimateFromDoc(doc);
        _financialBreakdown = FirestoreService.financialsFromDoc(doc);
        _selectedCapacityKw = (doc['selectedCapacityKw'] as num).toDouble();
        _monthlyBill = _financialBreakdown.baselineMonthlyBill;
        _hasLoadedFromFirestore = true;
      }
    } catch (e) {
      debugPrint('SolarSessionState.loadFromFirestore failed: $e');
      // Silently fall back to defaults — the user can still proceed
    } finally {
      _isLoadingFromFirestore = false;
      notifyListeners();
    }
  }

  // ─── Persist IDs ─────────────────────────────────────────────────────────

  Future<void> _persistIds() async {
    final uid = AuthService().uid;
    if (uid == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_propertyId != null) {
      await prefs.setString('propertyId_$uid', _propertyId!);
    }
    if (_rooftopId != null) {
      await prefs.setString('rooftopId_$uid', _rooftopId!);
    }
    if (_analysisId != null) {
      await prefs.setString('analysisId_$uid', _analysisId!);
    }
    if (_rooftopImageUrl != null) {
      await prefs.setString('rooftopImageUrl_$uid', _rooftopImageUrl!);
    }
    if (_rooftopImageStoragePath != null) {
      await prefs.setString(
        'rooftopImageStoragePath_$uid',
        _rooftopImageStoragePath!,
      );
    }
  }

  // ─── Setters (write-through to Firestore) ─────────────────────────────────

  /// Updates the selected property location and saves to Firestore.
  Future<void> setProperty(PropertyLocation property) async {
    _selectedProperty = property;
    _recalculateDerived();
    notifyListeners();
    await _savePropertyToFirestore();
  }

  /// Updates property characteristics and saves to Firestore.
  Future<void> updatePropertyDetails({
    String? propertyType,
    String? roofType,
    double? monthlyBill,
    double? sanctionedLoadKw,
  }) async {
    if (propertyType != null) _propertyType = propertyType;
    if (roofType != null) _roofType = roofType;
    if (monthlyBill != null) _monthlyBill = monthlyBill;
    if (sanctionedLoadKw != null) _sanctionedLoadKw = sanctionedLoadKw;

    _recalculateDerived();
    notifyListeners();
    await _savePropertyToFirestore();
  }

  /// Updates rooftop analysis and saves to Firestore.
  Future<void> updateRooftopAnalysis({
    required double grossAreaSqFt,
    required double usableAreaSqFt,
    double? obstacleAreaSqFt,
    double? viabilityPercent,
    int? obstacleCount,
    double? slopeDegrees,
    String? orientation,
    double? irradianceKwhPerM2,
    String? imageUrl,
    String? imageStoragePath,
  }) async {
    final obstacle =
        obstacleAreaSqFt ??
        (grossAreaSqFt - usableAreaSqFt).clamp(0.0, double.infinity);
    final viability =
        viabilityPercent ??
        (grossAreaSqFt > 0
            ? (usableAreaSqFt / grossAreaSqFt * 100).roundToDouble()
            : 78.0);

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

    if (imageUrl != null) _rooftopImageUrl = imageUrl;
    if (imageStoragePath != null) _rooftopImageStoragePath = imageStoragePath;

    _selectedCapacityKw = SolarCalculatorService.recommendCapacityFromArea(
      _rooftopAnalysis,
    );
    _recalculateDerived();
    notifyListeners();
    await _saveRooftopAndAnalysisToFirestore();
  }

  /// Updates selected capacity (from slider) and saves to Firestore.
  Future<void> setSelectedCapacity(double capacityKw) async {
    _selectedCapacityKw = capacityKw;
    _recalculateDerived();
    notifyListeners();
    await _saveAnalysisToFirestore();
  }

  // ─── Firestore write helpers ──────────────────────────────────────────────

  Future<void> _savePropertyToFirestore() async {
    final uid = AuthService().uid;
    if (uid == null) return;
    try {
      if (_propertyId == null) {
        _propertyId = await FirestoreService().saveProperty(
          uid: uid,
          location: _selectedProperty,
          propertyType: _propertyType,
          roofType: _roofType,
          monthlyBill: _monthlyBill,
          sanctionedLoadKw: _sanctionedLoadKw,
        );
      } else {
        await FirestoreService().updateProperty(
          uid: uid,
          propertyId: _propertyId!,
          propertyType: _propertyType,
          roofType: _roofType,
          monthlyBill: _monthlyBill,
          sanctionedLoadKw: _sanctionedLoadKw,
        );
      }
      await _persistIds();
    } catch (e) {
      debugPrint('SolarSessionState._savePropertyToFirestore failed: $e');
    }
  }

  Future<void> _saveRooftopAndAnalysisToFirestore() async {
    final uid = AuthService().uid;
    if (uid == null) return;
    try {
      // Ensure property exists first
      if (_propertyId == null) {
        await _savePropertyToFirestore();
      }
      if (_propertyId == null) return;

      _rooftopId ??= await FirestoreService().saveRooftop(
        uid: uid,
        propertyId: _propertyId!,
        analysis: _rooftopAnalysis,
        imageUrl: _rooftopImageUrl,
        imageStoragePath: _rooftopImageStoragePath,
      );
      await _saveAnalysisToFirestore();
      await _persistIds();
    } catch (e) {
      debugPrint(
        'SolarSessionState._saveRooftopAndAnalysisToFirestore failed: $e',
      );
    }
  }

  Future<void> _saveAnalysisToFirestore() async {
    final uid = AuthService().uid;
    if (uid == null || _propertyId == null || _rooftopId == null) return;
    try {
      _analysisId = await FirestoreService().saveAnalysis(
        uid: uid,
        propertyId: _propertyId!,
        rooftopId: _rooftopId!,
        estimate: _solarEstimate,
        financials: _financialBreakdown,
        selectedCapacityKw: _selectedCapacityKw,
      );
      await _persistIds();
    } catch (e) {
      debugPrint('SolarSessionState._saveAnalysisToFirestore failed: $e');
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  /// Resets the session and clears persisted IDs.
  Future<void> reset() async {
    final uid = AuthService().uid;
    _propertyId = null;
    _rooftopId = null;
    _analysisId = null;
    _rooftopImageUrl = null;
    _rooftopImageStoragePath = null;
    _hasLoadedFromFirestore = false;
    _resetToDefaults();
    notifyListeners();
    if (uid != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('propertyId_$uid');
      await prefs.remove('rooftopId_$uid');
      await prefs.remove('analysisId_$uid');
      await prefs.remove('rooftopImageUrl_$uid');
      await prefs.remove('rooftopImageStoragePath_$uid');
    }
  }
}
