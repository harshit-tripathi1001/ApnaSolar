import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/financial_breakdown.dart';
import '../models/installer_provider.dart';
import '../models/property_location.dart';
import '../models/rooftop_analysis.dart';
import '../models/solar_estimate.dart';
import '../models/user_solar_project.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'solar_calculator_service.dart';

/// Central singleton maintaining the current solar assessment session.
///
/// On startup, attempts to load the most recent analysis and project from Firestore
/// for the signed-in user. Falls back to sensible defaults when offline or when
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

  // ─── Active User & Firestore IDs ──────────────────────────────────────────

  String? _currentUid;
  String? _projectId;
  String? _propertyId;
  String? _rooftopId;
  String? _analysisId;
  String? _rooftopImageUrl;
  String? _rooftopImageStoragePath;

  String? get projectId => _projectId;
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

  // ─── User-Entered Step Tracking & Attachments ─────────────────────────────

  UserSolarProject? _activeProject;
  VerifiedInstaller? _selectedInstaller;
  List<String> _uploadedBills = [];
  List<Offset>? _calibratedVertices;

  bool _hasUserSetLocation = false;
  bool _hasUserSetProperty = false;
  bool _hasUserSetRooftop = false;
  bool _hasUserSetCapacity = false;
  bool _isAuditCompleted = false;

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

  UserSolarProject? get activeProject => _activeProject;
  VerifiedInstaller? get selectedInstaller => _selectedInstaller;
  List<String> get uploadedBills => List.unmodifiable(_uploadedBills);
  List<Offset>? get calibratedVertices => _calibratedVertices;

  bool get hasUserSetLocation => _hasUserSetLocation;
  bool get hasUserSetProperty => _hasUserSetProperty;
  bool get hasUserSetRooftop => _hasUserSetRooftop;
  bool get hasUserSetCapacity => _hasUserSetCapacity;
  bool get isAuditCompleted => _isAuditCompleted;
  bool get hasCompletedAssessment =>
      _isAuditCompleted ||
      (_hasUserSetLocation &&
          _hasUserSetProperty &&
          _hasUserSetRooftop &&
          _hasUserSetCapacity);

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
    _uploadedBills = [];
    _calibratedVertices = null;
    _selectedInstaller = null;
    _hasUserSetLocation = false;
    _hasUserSetProperty = false;
    _hasUserSetRooftop = false;
    _hasUserSetCapacity = false;
    _isAuditCompleted = false;
    _activeProject = null;
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

  void _syncActiveProject() {
    final uid = AuthService().uid ?? '';
    final existing = _activeProject;
    final now = DateTime.now();
    _projectId ??= existing?.id ?? 'proj_${now.millisecondsSinceEpoch}';

    _activeProject = UserSolarProject(
      id: _projectId!,
      userId: uid,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      location: _hasUserSetLocation ? _selectedProperty : existing?.location,
      hasLocation: _hasUserSetLocation,
      propertyType: _hasUserSetProperty
          ? _propertyType
          : existing?.propertyType,
      roofType: _hasUserSetProperty ? _roofType : existing?.roofType,
      monthlyBill: _hasUserSetProperty ? _monthlyBill : existing?.monthlyBill,
      sanctionedLoadKw: _hasUserSetProperty
          ? _sanctionedLoadKw
          : existing?.sanctionedLoadKw,
      uploadedBills: _uploadedBills,
      hasPropertyDetails: _hasUserSetProperty,
      rooftopAnalysis: _hasUserSetRooftop
          ? _rooftopAnalysis
          : existing?.rooftopAnalysis,
      rooftopImageUrl: _rooftopImageUrl ?? existing?.rooftopImageUrl,
      rooftopVertices: _calibratedVertices ?? existing?.rooftopVertices,
      hasRooftop: _hasUserSetRooftop,
      selectedCapacityKw: _hasUserSetCapacity
          ? _selectedCapacityKw
          : existing?.selectedCapacityKw,
      solarEstimate: (_hasUserSetCapacity || _hasUserSetRooftop)
          ? _solarEstimate
          : existing?.solarEstimate,
      financialBreakdown: (_hasUserSetCapacity || _hasUserSetProperty)
          ? _financialBreakdown
          : existing?.financialBreakdown,
      hasSystemSizing: _hasUserSetCapacity || _hasUserSetRooftop,
      isAuditCompleted: _isAuditCompleted,
      auditCompletedAt: _isAuditCompleted
          ? (existing?.auditCompletedAt ?? now)
          : null,
      selectedInstaller: _selectedInstaller ?? existing?.selectedInstaller,
      status: _selectedInstaller != null
          ? 'Installer Connected'
          : (_isAuditCompleted ? 'Audit Completed' : 'In Progress'),
    );
  }

  // ─── Firebase load ────────────────────────────────────────────────────────

  /// Loads the most recent analysis and project from Firestore for the signed-in user.
  ///
  /// Call this once after Firebase initializes and auth state is known.
  Future<void> loadFromFirestore() async {
    final uid = AuthService().uid;
    if (uid == null) return;
    _currentUid = uid;

    _isLoadingFromFirestore = true;
    notifyListeners();

    try {
      // Restore persisted IDs
      final prefs = await SharedPreferences.getInstance();
      _projectId = prefs.getString('projectId_$uid');
      _propertyId = prefs.getString('propertyId_$uid');
      _rooftopId = prefs.getString('rooftopId_$uid');
      _analysisId = prefs.getString('analysisId_$uid');
      _rooftopImageUrl = prefs.getString('rooftopImageUrl_$uid');
      _rooftopImageStoragePath = prefs.getString(
        'rooftopImageStoragePath_$uid',
      );

      // Try loading latest UserSolarProject
      final proj = await FirestoreService().getLatestUserProject(uid);
      if (proj != null) {
        _activeProject = proj;
        _projectId = proj.id;
        if (proj.hasLocation && proj.location != null) {
          _selectedProperty = proj.location!;
          _hasUserSetLocation = true;
        }
        if (proj.hasPropertyDetails) {
          if (proj.propertyType != null) _propertyType = proj.propertyType!;
          if (proj.roofType != null) _roofType = proj.roofType!;
          if (proj.monthlyBill != null) _monthlyBill = proj.monthlyBill!;
          if (proj.sanctionedLoadKw != null) {
            _sanctionedLoadKw = proj.sanctionedLoadKw!;
          }
          _uploadedBills = List.from(proj.uploadedBills);
          _hasUserSetProperty = true;
        }
        if (proj.hasRooftop && proj.rooftopAnalysis != null) {
          _rooftopAnalysis = proj.rooftopAnalysis!;
          _rooftopImageUrl = proj.rooftopImageUrl;
          _calibratedVertices = proj.rooftopVertices != null
              ? List.from(proj.rooftopVertices!)
              : null;
          _hasUserSetRooftop = true;
        }
        if (proj.hasSystemSizing && proj.selectedCapacityKw != null) {
          _selectedCapacityKw = proj.selectedCapacityKw!;
          _hasUserSetCapacity = true;
        }
        _isAuditCompleted = proj.isAuditCompleted;
        if (proj.selectedInstaller != null) {
          _selectedInstaller = proj.selectedInstaller;
        }
        _recalculateDerived();
        _hasLoadedFromFirestore = true;
      } else {
        final doc = await FirestoreService().getLatestAnalysis(uid);
        if (doc != null) {
          _analysisId = doc['id'] as String?;
          _solarEstimate = FirestoreService.estimateFromDoc(doc);
          _financialBreakdown = FirestoreService.financialsFromDoc(doc);
          _selectedCapacityKw = (doc['selectedCapacityKw'] as num).toDouble();
          _monthlyBill = _financialBreakdown.baselineMonthlyBill;
          _hasLoadedFromFirestore = true;
        }
      }
      _syncActiveProject();
    } catch (e) {
      debugPrint('SolarSessionState.loadFromFirestore failed: $e');
    } finally {
      _isLoadingFromFirestore = false;
      notifyListeners();
    }
  }

  /// Resets state when the authenticated user changes.
  void resetForUser(String? newUid) {
    if (_currentUid != newUid) {
      _currentUid = newUid;
      reset();
      if (newUid != null) {
        loadFromFirestore();
      }
    }
  }

  // ─── Persist IDs ─────────────────────────────────────────────────────────

  Future<void> _persistIds() async {
    final uid = AuthService().uid;
    if (uid == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_projectId != null) {
      await prefs.setString('projectId_$uid', _projectId!);
    }
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
    _hasUserSetLocation = true;
    _recalculateDerived();
    _syncActiveProject();
    notifyListeners();
    await _savePropertyToFirestore();
    await _saveActiveProjectToFirestore();
  }

  /// Updates property characteristics and saves to Firestore.
  Future<void> updatePropertyDetails({
    String? propertyType,
    String? roofType,
    double? monthlyBill,
    double? sanctionedLoadKw,
    List<String>? uploadedBills,
  }) async {
    if (propertyType != null) _propertyType = propertyType;
    if (roofType != null) _roofType = roofType;
    if (monthlyBill != null) _monthlyBill = monthlyBill;
    if (sanctionedLoadKw != null) _sanctionedLoadKw = sanctionedLoadKw;
    if (uploadedBills != null) _uploadedBills = List.from(uploadedBills);
    _hasUserSetProperty = true;

    _recalculateDerived();
    _syncActiveProject();
    notifyListeners();
    await _savePropertyToFirestore();
    await _saveActiveProjectToFirestore();
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
    List<Offset>? vertices,
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
    if (vertices != null) _calibratedVertices = List.from(vertices);
    _hasUserSetRooftop = true;

    _selectedCapacityKw = SolarCalculatorService.recommendCapacityFromArea(
      _rooftopAnalysis,
    );
    _recalculateDerived();
    _syncActiveProject();
    notifyListeners();
    await _saveRooftopAndAnalysisToFirestore();
    await _saveActiveProjectToFirestore();
  }

  /// Updates rooftop polygon vertices.
  void updateRooftopVertices(List<Offset> vertices) {
    _calibratedVertices = List.from(vertices);
    _hasUserSetRooftop = true;
    _syncActiveProject();
    notifyListeners();
  }

  /// Updates selected capacity (from slider) and saves to Firestore.
  Future<void> setSelectedCapacity(double capacityKw) async {
    _selectedCapacityKw = capacityKw;
    _hasUserSetCapacity = true;
    _recalculateDerived();
    _syncActiveProject();
    notifyListeners();
    await _saveAnalysisToFirestore();
    await _saveActiveProjectToFirestore();
  }

  /// Marks official audit as completed.
  Future<void> markAuditCompleted() async {
    _isAuditCompleted = true;
    _syncActiveProject();
    notifyListeners();
    await _saveActiveProjectToFirestore();
  }

  /// Sets the selected verified installer / contractor and persists to Firestore.
  Future<void> setSelectedInstaller(VerifiedInstaller installer) async {
    _selectedInstaller = installer.copyWith(selectedAt: DateTime.now());
    _syncActiveProject();
    notifyListeners();
    final uid = AuthService().uid;
    if (uid != null && _activeProject != null) {
      await FirestoreService().saveSelectedInstaller(
        uid: uid,
        projectId: _activeProject!.id,
        installer: _selectedInstaller!,
      );
      await _saveActiveProjectToFirestore();
    }
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

  Future<void> _saveActiveProjectToFirestore() async {
    final uid = AuthService().uid;
    if (uid == null || _activeProject == null) return;
    try {
      await FirestoreService().saveUserProject(
        uid: uid,
        project: _activeProject!,
      );
      await _persistIds();
    } catch (e) {
      debugPrint('SolarSessionState._saveActiveProjectToFirestore failed: $e');
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  /// Resets the session and clears persisted IDs.
  Future<void> reset() async {
    final uid = AuthService().uid;
    _projectId = null;
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
      await prefs.remove('projectId_$uid');
      await prefs.remove('propertyId_$uid');
      await prefs.remove('rooftopId_$uid');
      await prefs.remove('analysisId_$uid');
      await prefs.remove('rooftopImageUrl_$uid');
      await prefs.remove('rooftopImageStoragePath_$uid');
    }
  }
}
