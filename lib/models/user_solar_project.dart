import 'package:flutter/material.dart';

import 'financial_breakdown.dart';
import 'installer_provider.dart';
import 'property_location.dart';
import 'rooftop_analysis.dart';
import 'solar_estimate.dart';

/// Single unified, persistent data model representing a user's entire
/// solar project flow (Steps 1 through 5, and post-Step 5 installer selection).
class UserSolarProject {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Step 1: Location & Property Address ──────────────────────────────────
  final PropertyLocation? location;
  final bool hasLocation;

  // ── Step 2: Property Characteristics & Utility Bills ─────────────────────
  final String? propertyType;
  final String? roofType;
  final double? monthlyBill;
  final double? sanctionedLoadKw;
  final List<String> uploadedBills;
  final bool hasPropertyDetails;

  // ── Step 3: Rooftop Analysis & Physical Specs ────────────────────────────
  final RooftopAnalysis? rooftopAnalysis;
  final String? rooftopImageUrl;
  final List<Offset>? rooftopVertices;
  final bool hasRooftop;

  // ── Step 4: System Sizing, Capacity & Financials ─────────────────────────
  final double? selectedCapacityKw;
  final SolarEstimate? solarEstimate;
  final FinancialBreakdown? financialBreakdown;
  final bool hasSystemSizing;

  // ── Step 5: Official Solar Audit Report Status ───────────────────────────
  final bool isAuditCompleted;
  final DateTime? auditCompletedAt;

  // ── Post-Step 5: Selected Verified EPC Contractor / Verifier ─────────────
  final VerifiedInstaller? selectedInstaller;

  // ── Overall Project Lifecycle Status ─────────────────────────────────────
  final String status;

  const UserSolarProject({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.hasLocation = false,
    this.propertyType,
    this.roofType,
    this.monthlyBill,
    this.sanctionedLoadKw,
    this.uploadedBills = const [],
    this.hasPropertyDetails = false,
    this.rooftopAnalysis,
    this.rooftopImageUrl,
    this.rooftopVertices,
    this.hasRooftop = false,
    this.selectedCapacityKw,
    this.solarEstimate,
    this.financialBreakdown,
    this.hasSystemSizing = false,
    this.isAuditCompleted = false,
    this.auditCompletedAt,
    this.selectedInstaller,
    this.status = 'Draft',
  });

  /// Factory for a fresh empty project for a specific user
  factory UserSolarProject.empty(String userId) {
    final now = DateTime.now();
    return UserSolarProject(
      id: 'proj_${now.millisecondsSinceEpoch}',
      userId: userId,
      createdAt: now,
      updatedAt: now,
      status: 'Not Started',
    );
  }

  UserSolarProject copyWith({
    PropertyLocation? location,
    bool? hasLocation,
    String? propertyType,
    String? roofType,
    double? monthlyBill,
    double? sanctionedLoadKw,
    List<String>? uploadedBills,
    bool? hasPropertyDetails,
    RooftopAnalysis? rooftopAnalysis,
    String? rooftopImageUrl,
    List<Offset>? rooftopVertices,
    bool? hasRooftop,
    double? selectedCapacityKw,
    SolarEstimate? solarEstimate,
    FinancialBreakdown? financialBreakdown,
    bool? hasSystemSizing,
    bool? isAuditCompleted,
    DateTime? auditCompletedAt,
    VerifiedInstaller? selectedInstaller,
    String? status,
  }) {
    return UserSolarProject(
      id: id,
      userId: userId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      location: location ?? this.location,
      hasLocation: hasLocation ?? this.hasLocation,
      propertyType: propertyType ?? this.propertyType,
      roofType: roofType ?? this.roofType,
      monthlyBill: monthlyBill ?? this.monthlyBill,
      sanctionedLoadKw: sanctionedLoadKw ?? this.sanctionedLoadKw,
      uploadedBills: uploadedBills ?? this.uploadedBills,
      hasPropertyDetails: hasPropertyDetails ?? this.hasPropertyDetails,
      rooftopAnalysis: rooftopAnalysis ?? this.rooftopAnalysis,
      rooftopImageUrl: rooftopImageUrl ?? this.rooftopImageUrl,
      rooftopVertices: rooftopVertices ?? this.rooftopVertices,
      hasRooftop: hasRooftop ?? this.hasRooftop,
      selectedCapacityKw: selectedCapacityKw ?? this.selectedCapacityKw,
      solarEstimate: solarEstimate ?? this.solarEstimate,
      financialBreakdown: financialBreakdown ?? this.financialBreakdown,
      hasSystemSizing: hasSystemSizing ?? this.hasSystemSizing,
      isAuditCompleted: isAuditCompleted ?? this.isAuditCompleted,
      auditCompletedAt: auditCompletedAt ?? this.auditCompletedAt,
      selectedInstaller: selectedInstaller ?? this.selectedInstaller,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hasLocation': hasLocation,
      if (location != null)
        'location': {
          'formattedAddress': location!.formattedAddress,
          'locality': location!.locality,
          'city': location!.city,
          'state': location!.state,
          'postalCode': location!.postalCode,
          'latitude': location!.latitude,
          'longitude': location!.longitude,
          'peakSunHoursPerDay': location!.peakSunHoursPerDay,
        },
      'propertyType': propertyType,
      'roofType': roofType,
      'monthlyBill': monthlyBill,
      'sanctionedLoadKw': sanctionedLoadKw,
      'uploadedBills': uploadedBills,
      'hasPropertyDetails': hasPropertyDetails,
      if (rooftopAnalysis != null)
        'rooftopAnalysis': {
          'totalGrossAreaSqFt': rooftopAnalysis!.totalGrossAreaSqFt,
          'netUsableAreaSqFt': rooftopAnalysis!.netUsableAreaSqFt,
          'obstacleAreaSqFt': rooftopAnalysis!.obstacleAreaSqFt,
          'solarViabilityPercent': rooftopAnalysis!.solarViabilityPercent,
          'obstacleCount': rooftopAnalysis!.obstacleCount,
          'slopeDegrees': rooftopAnalysis!.slopeDegrees,
          'orientation': rooftopAnalysis!.orientation,
          'irradianceKwhPerM2': rooftopAnalysis!.irradianceKwhPerM2,
        },
      'rooftopImageUrl': rooftopImageUrl,
      if (rooftopVertices != null)
        'rooftopVertices': rooftopVertices!
            .map((v) => {'dx': v.dx, 'dy': v.dy})
            .toList(),
      'hasRooftop': hasRooftop,
      'selectedCapacityKw': selectedCapacityKw,
      if (solarEstimate != null)
        'solarEstimate': {
          'capacityKw': solarEstimate!.capacityKw,
          'panelCount': solarEstimate!.panelCount,
          'panelWattage': solarEstimate!.panelWattage,
          'panelType': solarEstimate!.panelType,
          'inverterCapacityKw': solarEstimate!.inverterCapacityKw,
          'dailyGenerationKwh': solarEstimate!.dailyGenerationKwh,
          'monthlyGenerationKwh': solarEstimate!.monthlyGenerationKwh,
          'annualGenerationKwh': solarEstimate!.annualGenerationKwh,
          'treeOffsetEquivalent': solarEstimate!.treeOffsetEquivalent,
          'co2OffsetTonnesPerYear': solarEstimate!.co2OffsetTonnesPerYear,
        },
      if (financialBreakdown != null)
        'financialBreakdown': {
          'grossTurnkeyCost': financialBreakdown!.grossTurnkeyCost,
          'centralDbtSubsidy': financialBreakdown!.centralDbtSubsidy,
          'netPayableCost': financialBreakdown!.netPayableCost,
          'baselineMonthlyBill': financialBreakdown!.baselineMonthlyBill,
          'projectedMonthlyBill': financialBreakdown!.projectedMonthlyBill,
          'monthlySavings': financialBreakdown!.monthlySavings,
          'annualSavings': financialBreakdown!.annualSavings,
          'paybackPeriodYears': financialBreakdown!.paybackPeriodYears,
          'cumulative25YearSavings':
              financialBreakdown!.cumulative25YearSavings,
        },
      'hasSystemSizing': hasSystemSizing,
      'isAuditCompleted': isAuditCompleted,
      'auditCompletedAt': auditCompletedAt?.toIso8601String(),
      if (selectedInstaller != null)
        'selectedInstaller': selectedInstaller!.toJson(),
      'status': status,
    };
  }

  factory UserSolarProject.fromJson(Map<String, dynamic> json, String id) {
    PropertyLocation? loc;
    if (json['location'] != null) {
      final l = json['location'] as Map<String, dynamic>;
      loc = PropertyLocation(
        formattedAddress: l['formattedAddress'] as String? ?? '',
        locality: l['locality'] as String? ?? '',
        city: l['city'] as String? ?? '',
        state: l['state'] as String? ?? '',
        postalCode: l['postalCode'] as String? ?? '',
        latitude: (l['latitude'] as num?)?.toDouble() ?? 12.9719,
        longitude: (l['longitude'] as num?)?.toDouble() ?? 77.6412,
        peakSunHoursPerDay:
            (l['peakSunHoursPerDay'] as num?)?.toDouble() ?? 5.2,
      );
    }

    RooftopAnalysis? roof;
    if (json['rooftopAnalysis'] != null) {
      final r = json['rooftopAnalysis'] as Map<String, dynamic>;
      roof = RooftopAnalysis(
        totalGrossAreaSqFt:
            (r['totalGrossAreaSqFt'] as num?)?.toDouble() ?? 1440.0,
        netUsableAreaSqFt:
            (r['netUsableAreaSqFt'] as num?)?.toDouble() ?? 1120.0,
        obstacleAreaSqFt: (r['obstacleAreaSqFt'] as num?)?.toDouble() ?? 320.0,
        solarViabilityPercent:
            (r['solarViabilityPercent'] as num?)?.toDouble() ?? 78.0,
        obstacleCount: (r['obstacleCount'] as num?)?.toInt() ?? 2,
        slopeDegrees: (r['slopeDegrees'] as num?)?.toDouble() ?? 0.0,
        orientation: r['orientation'] as String? ?? '180° South',
        irradianceKwhPerM2:
            (r['irradianceKwhPerM2'] as num?)?.toDouble() ?? 5.4,
      );
    }

    List<Offset>? vertices;
    if (json['rooftopVertices'] != null) {
      final vList = json['rooftopVertices'] as List<dynamic>;
      vertices = vList.map((v) {
        final m = v as Map<String, dynamic>;
        return Offset((m['dx'] as num).toDouble(), (m['dy'] as num).toDouble());
      }).toList();
    }

    SolarEstimate? estimate;
    if (json['solarEstimate'] != null) {
      final e = json['solarEstimate'] as Map<String, dynamic>;
      estimate = SolarEstimate(
        capacityKw: (e['capacityKw'] as num?)?.toDouble() ?? 5.8,
        panelCount: (e['panelCount'] as num?)?.toInt() ?? 12,
        panelWattage: (e['panelWattage'] as num?)?.toInt() ?? 550,
        panelType: e['panelType'] as String? ?? 'Tier-1 Mono',
        inverterCapacityKw:
            (e['inverterCapacityKw'] as num?)?.toDouble() ?? 5.0,
        dailyGenerationKwh:
            (e['dailyGenerationKwh'] as num?)?.toDouble() ?? 23.2,
        monthlyGenerationKwh:
            (e['monthlyGenerationKwh'] as num?)?.toDouble() ?? 696.0,
        annualGenerationKwh:
            (e['annualGenerationKwh'] as num?)?.toDouble() ?? 8352.0,
        treeOffsetEquivalent:
            (e['treeOffsetEquivalent'] as num?)?.toInt() ?? 138,
        co2OffsetTonnesPerYear:
            (e['co2OffsetTonnesPerYear'] as num?)?.toDouble() ?? 6.8,
      );
    }

    FinancialBreakdown? fin;
    if (json['financialBreakdown'] != null) {
      final f = json['financialBreakdown'] as Map<String, dynamic>;
      fin = FinancialBreakdown(
        grossTurnkeyCost:
            (f['grossTurnkeyCost'] as num?)?.toDouble() ?? 340000.0,
        centralDbtSubsidy:
            (f['centralDbtSubsidy'] as num?)?.toDouble() ?? 78000.0,
        netPayableCost: (f['netPayableCost'] as num?)?.toDouble() ?? 262000.0,
        baselineMonthlyBill:
            (f['baselineMonthlyBill'] as num?)?.toDouble() ?? 3850.0,
        projectedMonthlyBill:
            (f['projectedMonthlyBill'] as num?)?.toDouble() ?? 500.0,
        monthlySavings: (f['monthlySavings'] as num?)?.toDouble() ?? 3350.0,
        annualSavings: (f['annualSavings'] as num?)?.toDouble() ?? 40200.0,
        paybackPeriodYears:
            (f['paybackPeriodYears'] as num?)?.toDouble() ?? 3.2,
        cumulative25YearSavings:
            (f['cumulative25YearSavings'] as num?)?.toDouble() ?? 980000.0,
      );
    }

    VerifiedInstaller? inst;
    if (json['selectedInstaller'] != null) {
      inst = VerifiedInstaller.fromJson(
        json['selectedInstaller'] as Map<String, dynamic>,
      );
    }

    return UserSolarProject(
      id: id,
      userId: json['userId'] as String? ?? 'guest',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      location: loc,
      hasLocation: json['hasLocation'] as bool? ?? (loc != null),
      propertyType: json['propertyType'] as String?,
      roofType: json['roofType'] as String?,
      monthlyBill: (json['monthlyBill'] as num?)?.toDouble(),
      sanctionedLoadKw: (json['sanctionedLoadKw'] as num?)?.toDouble(),
      uploadedBills:
          (json['uploadedBills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hasPropertyDetails: json['hasPropertyDetails'] as bool? ?? false,
      rooftopAnalysis: roof,
      rooftopImageUrl: json['rooftopImageUrl'] as String?,
      rooftopVertices: vertices,
      hasRooftop: json['hasRooftop'] as bool? ?? (roof != null),
      selectedCapacityKw: (json['selectedCapacityKw'] as num?)?.toDouble(),
      solarEstimate: estimate,
      financialBreakdown: fin,
      hasSystemSizing: json['hasSystemSizing'] as bool? ?? (estimate != null),
      isAuditCompleted: json['isAuditCompleted'] as bool? ?? false,
      auditCompletedAt: json['auditCompletedAt'] != null
          ? DateTime.tryParse(json['auditCompletedAt'] as String)
          : null,
      selectedInstaller: inst,
      status: json['status'] as String? ?? 'Draft',
    );
  }
}
