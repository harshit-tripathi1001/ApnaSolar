import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/financial_breakdown.dart';
import '../models/installer_provider.dart';
import '../models/property_location.dart';
import '../models/rooftop_analysis.dart';
import '../models/solar_estimate.dart';
import '../models/user_solar_project.dart';

/// Firestore document paths for ApnaSolar.
///
/// Schema:
/// ```
/// users/{userId}
///   properties/{propertyId}
///     rooftops/{rooftopId}
///   analyses/{analysisId}
///   projects/{projectId}
/// ```
class FirestorePaths {
  FirestorePaths._();

  static String userDoc(String uid) => 'users/$uid';
  static String propertiesCol(String uid) => 'users/$uid/properties';
  static String propertyDoc(String uid, String propId) =>
      'users/$uid/properties/$propId';
  static String rooftopsCol(String uid, String propId) =>
      'users/$uid/properties/$propId/rooftops';
  static String rooftopDoc(String uid, String propId, String roofId) =>
      'users/$uid/properties/$propId/rooftops/$roofId';
  static String analysesCol(String uid) => 'users/$uid/analyses';
  static String analysisDoc(String uid, String analysisId) =>
      'users/$uid/analyses/$analysisId';
  static String projectsCol(String uid) => 'users/$uid/projects';
  static String projectDoc(String uid, String projectId) =>
      'users/$uid/projects/$projectId';
}

/// Wraps Cloud Firestore with typed read/write operations for ApnaSolar.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User profile ─────────────────────────────────────────────────────────

  /// Creates or updates the user profile document.
  Future<void> upsertUserProfile({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    await _db.doc(FirestorePaths.userDoc(uid)).set({
      'uid': uid,
      'email': ?email,
      'displayName': ?displayName,
      'photoUrl': ?photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Fetches the user profile document from Firestore.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _db.doc(FirestorePaths.userDoc(uid)).get();
      return doc.data();
    } catch (e) {
      debugPrint('FirestoreService.getUserProfile error: $e');
      return null;
    }
  }

  /// Streams the user profile document from Firestore.
  Stream<Map<String, dynamic>?> userProfileStream(String uid) {
    try {
      return _db
          .doc(FirestorePaths.userDoc(uid))
          .snapshots()
          .map((snapshot) => snapshot.data());
    } catch (e) {
      debugPrint('FirestoreService.userProfileStream error: $e');
      return const Stream.empty();
    }
  }

  // ─── Properties ───────────────────────────────────────────────────────────

  /// Saves a [PropertyLocation] to Firestore and returns the document id.
  Future<String> saveProperty({
    required String uid,
    required PropertyLocation location,
    String? propertyType,
    String? roofType,
    double? monthlyBill,
    double? sanctionedLoadKw,
  }) async {
    final col = _db.collection(FirestorePaths.propertiesCol(uid));
    final data = {
      'formattedAddress': location.formattedAddress,
      'locality': location.locality,
      'city': location.city,
      'state': location.state,
      'postalCode': location.postalCode,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'peakSunHoursPerDay': location.peakSunHoursPerDay,
      'propertyType': ?propertyType,
      'roofType': ?roofType,
      'monthlyBillInr': ?monthlyBill,
      'sanctionedLoadKw': ?sanctionedLoadKw,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final doc = await col.add(data);
    return doc.id;
  }

  /// Updates an existing property document.
  Future<void> updateProperty({
    required String uid,
    required String propertyId,
    String? propertyType,
    String? roofType,
    double? monthlyBill,
    double? sanctionedLoadKw,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (propertyType != null) {
      updates['propertyType'] = propertyType;
    }
    if (roofType != null) {
      updates['roofType'] = roofType;
    }
    if (monthlyBill != null) {
      updates['monthlyBillInr'] = monthlyBill;
    }
    if (sanctionedLoadKw != null) {
      updates['sanctionedLoadKw'] = sanctionedLoadKw;
    }
    await _db.doc(FirestorePaths.propertyDoc(uid, propertyId)).update(updates);
  }

  /// Streams all properties for a user (most recently updated first).
  Stream<List<Map<String, dynamic>>> streamProperties(String uid) {
    return _db
        .collection(FirestorePaths.propertiesCol(uid))
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  // ─── Rooftops ─────────────────────────────────────────────────────────────

  /// Saves a rooftop analysis result to Firestore.
  Future<String> saveRooftop({
    required String uid,
    required String propertyId,
    required RooftopAnalysis analysis,
    String? imageUrl,
    String? imageStoragePath,
  }) async {
    final col = _db.collection(FirestorePaths.rooftopsCol(uid, propertyId));
    final doc = await col.add({
      'totalGrossAreaSqFt': analysis.totalGrossAreaSqFt,
      'netUsableAreaSqFt': analysis.netUsableAreaSqFt,
      'obstacleAreaSqFt': analysis.obstacleAreaSqFt,
      'solarViabilityPercent': analysis.solarViabilityPercent,
      'obstacleCount': analysis.obstacleCount,
      'slopeDegrees': analysis.slopeDegrees,
      'orientation': analysis.orientation,
      'irradianceKwhPerM2': analysis.irradianceKwhPerM2,
      'imageUrl': ?imageUrl,
      'imageStoragePath': ?imageStoragePath,
      'analyzedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // ─── Analyses ─────────────────────────────────────────────────────────────

  /// Saves a complete solar analysis result to Firestore.
  Future<String> saveAnalysis({
    required String uid,
    required String propertyId,
    required String rooftopId,
    required SolarEstimate estimate,
    required FinancialBreakdown financials,
    required double selectedCapacityKw,
  }) async {
    final col = _db.collection(FirestorePaths.analysesCol(uid));
    final doc = await col.add({
      'propertyId': propertyId,
      'rooftopId': rooftopId,
      // Estimate
      'capacityKw': estimate.capacityKw,
      'panelCount': estimate.panelCount,
      'panelWattage': estimate.panelWattage,
      'panelType': estimate.panelType,
      'inverterCapacityKw': estimate.inverterCapacityKw,
      'dailyGenerationKwh': estimate.dailyGenerationKwh,
      'monthlyGenerationKwh': estimate.monthlyGenerationKwh,
      'annualGenerationKwh': estimate.annualGenerationKwh,
      'treeOffsetEquivalent': estimate.treeOffsetEquivalent,
      'co2OffsetTonnesPerYear': estimate.co2OffsetTonnesPerYear,
      // Financials
      'grossTurnkeyCost': financials.grossTurnkeyCost,
      'centralDbtSubsidy': financials.centralDbtSubsidy,
      'netPayableCost': financials.netPayableCost,
      'baselineMonthlyBill': financials.baselineMonthlyBill,
      'projectedMonthlyBill': financials.projectedMonthlyBill,
      'monthlySavings': financials.monthlySavings,
      'annualSavings': financials.annualSavings,
      'paybackPeriodYears': financials.paybackPeriodYears,
      'cumulative25YearSavings': financials.cumulative25YearSavings,
      'selectedCapacityKw': selectedCapacityKw,
      'analyzedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Returns the most recent analysis for a user.
  Future<Map<String, dynamic>?> getLatestAnalysis(String uid) async {
    final snap = await _db
        .collection(FirestorePaths.analysesCol(uid))
        .orderBy('analyzedAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return {'id': snap.docs.first.id, ...snap.docs.first.data()};
  }

  /// Streams all analyses for a user.
  Stream<List<Map<String, dynamic>>> streamAnalyses(String uid) {
    return _db
        .collection(FirestorePaths.analysesCol(uid))
        .orderBy('analyzedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  /// Converts a Firestore document map back into a [SolarEstimate].
  static SolarEstimate estimateFromDoc(Map<String, dynamic> doc) {
    return SolarEstimate(
      capacityKw: (doc['capacityKw'] as num).toDouble(),
      panelCount: (doc['panelCount'] as num).toInt(),
      panelWattage: (doc['panelWattage'] as num).toInt(),
      panelType: doc['panelType'] as String,
      inverterCapacityKw: (doc['inverterCapacityKw'] as num).toDouble(),
      dailyGenerationKwh: (doc['dailyGenerationKwh'] as num).toDouble(),
      monthlyGenerationKwh: (doc['monthlyGenerationKwh'] as num).toDouble(),
      annualGenerationKwh: (doc['annualGenerationKwh'] as num).toDouble(),
      treeOffsetEquivalent: (doc['treeOffsetEquivalent'] as num).toInt(),
      co2OffsetTonnesPerYear: (doc['co2OffsetTonnesPerYear'] as num).toDouble(),
    );
  }

  /// Converts a Firestore document map back into a [FinancialBreakdown].
  static FinancialBreakdown financialsFromDoc(Map<String, dynamic> doc) {
    return FinancialBreakdown(
      grossTurnkeyCost: (doc['grossTurnkeyCost'] as num).toDouble(),
      centralDbtSubsidy: (doc['centralDbtSubsidy'] as num).toDouble(),
      netPayableCost: (doc['netPayableCost'] as num).toDouble(),
      baselineMonthlyBill: (doc['baselineMonthlyBill'] as num).toDouble(),
      projectedMonthlyBill: (doc['projectedMonthlyBill'] as num).toDouble(),
      monthlySavings: (doc['monthlySavings'] as num).toDouble(),
      annualSavings: (doc['annualSavings'] as num).toDouble(),
      paybackPeriodYears: (doc['paybackPeriodYears'] as num).toDouble(),
      cumulative25YearSavings: (doc['cumulative25YearSavings'] as num)
          .toDouble(),
    );
  }

  /// Converts a Firestore document map back into a [PropertyLocation].
  static PropertyLocation locationFromDoc(Map<String, dynamic> doc) {
    return PropertyLocation(
      formattedAddress: doc['formattedAddress'] as String,
      locality: doc['locality'] as String,
      city: doc['city'] as String,
      state: doc['state'] as String,
      postalCode: doc['postalCode'] as String,
      latitude: (doc['latitude'] as num).toDouble(),
      longitude: (doc['longitude'] as num).toDouble(),
      peakSunHoursPerDay: (doc['peakSunHoursPerDay'] as num? ?? 5.2).toDouble(),
    );
  }

  // ─── Solar Projects ───────────────────────────────────────────────────────

  /// Saves or updates a unified [UserSolarProject].
  Future<void> saveUserProject({
    required String uid,
    required UserSolarProject project,
  }) async {
    final docRef = _db.doc(FirestorePaths.projectDoc(uid, project.id));
    await docRef.set(project.toJson(), SetOptions(merge: true));
  }

  /// Gets the most recent project for a user.
  Future<UserSolarProject?> getLatestUserProject(String uid) async {
    try {
      final snap = await _db
          .collection(FirestorePaths.projectsCol(uid))
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return UserSolarProject.fromJson(
        snap.docs.first.data(),
        snap.docs.first.id,
      );
    } catch (e) {
      debugPrint('FirestoreService.getLatestUserProject error: $e');
      return null;
    }
  }

  /// Streams user projects ordered by updatedAt.
  Stream<List<UserSolarProject>> streamUserProjects(String uid) {
    return _db
        .collection(FirestorePaths.projectsCol(uid))
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => UserSolarProject.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Saves the selected installer to the project.
  Future<void> saveSelectedInstaller({
    required String uid,
    required String projectId,
    required VerifiedInstaller installer,
  }) async {
    final docRef = _db.doc(FirestorePaths.projectDoc(uid, projectId));
    await docRef.set({
      'selectedInstaller': installer.toJson(),
      'status': 'Installer Connected',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
