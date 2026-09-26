import 'dart:async';

import '../models/rooftop_analysis.dart';
import 'solar_calculator_service.dart';
import 'solar_session_service.dart';

/// The discrete stages of the rooftop analysis lifecycle.
enum AnalysisPhase {
  input,
  analysing,
  rooftopDetected,
  areaEstimated,
  solarPotentialCalculated,
  resultReady,
}

/// Snapshot of the rooftop analysis progress and intermediate values.
class AnalysisProgressState {
  final AnalysisPhase phase;
  final double progress; // 0.0 to 1.0
  final String statusTitle;
  final String statusDescription;
  final double detectedGrossAreaSqFt;
  final double usableAreaSqFt;
  final double obstacleAreaSqFt;
  final int obstacleCount;
  final double irradianceKwhPerM2;
  final double slopeDegrees;
  final String orientation;
  final double recommendedCapacityKw;
  final int panelCount;
  final List<AnalysisPhase> completedPhases;

  const AnalysisProgressState({
    required this.phase,
    required this.progress,
    required this.statusTitle,
    required this.statusDescription,
    required this.detectedGrossAreaSqFt,
    required this.usableAreaSqFt,
    required this.obstacleAreaSqFt,
    required this.obstacleCount,
    required this.irradianceKwhPerM2,
    required this.slopeDegrees,
    required this.orientation,
    required this.recommendedCapacityKw,
    required this.panelCount,
    required this.completedPhases,
  });

  bool get isComplete => phase == AnalysisPhase.resultReady;

  bool isPhaseComplete(AnalysisPhase targetPhase) =>
      completedPhases.contains(targetPhase);

  bool isPhaseActive(AnalysisPhase targetPhase) => phase == targetPhase;

  RooftopAnalysis toRooftopAnalysis() {
    return RooftopAnalysis(
      totalGrossAreaSqFt: detectedGrossAreaSqFt,
      netUsableAreaSqFt: usableAreaSqFt,
      obstacleAreaSqFt: obstacleAreaSqFt,
      solarViabilityPercent: detectedGrossAreaSqFt > 0
          ? (usableAreaSqFt / detectedGrossAreaSqFt * 100).roundToDouble()
          : 78.0,
      obstacleCount: obstacleCount,
      slopeDegrees: slopeDegrees,
      orientation: orientation,
      irradianceKwhPerM2: irradianceKwhPerM2,
    );
  }
}

/// Abstract contract for rooftop vision analysis engines.
abstract class RooftopAnalysisService {
  Stream<AnalysisProgressState> get progressStream;
  AnalysisProgressState get currentState;

  Future<void> startAnalysis({
    double? initialGrossArea,
    double? initialUsableArea,
    Duration stepDuration = const Duration(milliseconds: 750),
  });

  void fastForward();
  void dispose();
}

/// Deterministic mock implementation of [RooftopAnalysisService] matching the Stitch flow.
class MockRooftopAnalysisService implements RooftopAnalysisService {
  final _controller = StreamController<AnalysisProgressState>.broadcast();
  Timer? _stepTimer;
  bool _isFastForwarded = false;
  late AnalysisProgressState _currentState;

  MockRooftopAnalysisService({
    double? defaultGrossArea,
    double? defaultUsableArea,
  }) {
    final session = SolarSessionState();
    final gross = defaultGrossArea ?? session.rooftopAnalysis.totalGrossAreaSqFt;
    final usable = defaultUsableArea ?? session.rooftopAnalysis.netUsableAreaSqFt;

    _currentState = _createState(
      phase: AnalysisPhase.input,
      grossArea: gross,
      usableArea: usable,
      completed: [],
    );
  }

  @override
  Stream<AnalysisProgressState> get progressStream => _controller.stream;

  @override
  AnalysisProgressState get currentState => _currentState;

  AnalysisProgressState _createState({
    required AnalysisPhase phase,
    required double grossArea,
    required double usableArea,
    required List<AnalysisPhase> completed,
  }) {
    double progress = 0.0;
    String title = '';
    String desc = '';

    switch (phase) {
      case AnalysisPhase.input:
        progress = 0.10;
        title = 'Ingesting satellite imagery...';
        desc = 'Calibrating 0.3m resolution aerial capture and LiDAR reticle.';
        break;
      case AnalysisPhase.analysing:
        progress = 0.30;
        title = 'Mapping your sun exposure...';
        desc = 'Synthesizing ISRO INSAT solar irradiance data with AI terrace segmentation.';
        break;
      case AnalysisPhase.rooftopDetected:
        progress = 0.55;
        title = 'Terrace Boundary Detected';
        desc = 'Identified reinforced parapet buffers and peripheral dimensions.';
        break;
      case AnalysisPhase.areaEstimated:
        progress = 0.75;
        title = 'Shadow Obstacles Isolated';
        desc = 'Excluded Mumty stair tower and overhead Sintex water tank shadows.';
        break;
      case AnalysisPhase.solarPotentialCalculated:
        progress = 0.90;
        title = 'Calculating Optimal Panel Count';
        desc = 'Optimizing bi-facial mono-PERC layout for flat terrace RCC.';
        break;
      case AnalysisPhase.resultReady:
        progress = 1.0;
        title = 'Solar Assessment Complete!';
        desc = 'High-precision terrace model and generation forecast ready to view.';
        break;
    }

    final capacity = SolarCalculatorService.recommendCapacityFromArea(
      RooftopAnalysis(
        totalGrossAreaSqFt: grossArea,
        netUsableAreaSqFt: usableArea,
        obstacleAreaSqFt: (grossArea - usableArea).clamp(0.0, double.infinity),
        solarViabilityPercent: grossArea > 0 ? (usableArea / grossArea * 100).roundToDouble() : 78.0,
        obstacleCount: 2,
      ),
    );

    final panelCount = (capacity * 1000 / 550).ceil();

    return AnalysisProgressState(
      phase: phase,
      progress: progress,
      statusTitle: title,
      statusDescription: desc,
      detectedGrossAreaSqFt: grossArea,
      usableAreaSqFt: usableArea,
      obstacleAreaSqFt: (grossArea - usableArea).clamp(0.0, double.infinity),
      obstacleCount: 2,
      irradianceKwhPerM2: 5.4,
      slopeDegrees: 0.0,
      orientation: '180° South',
      recommendedCapacityKw: capacity,
      panelCount: panelCount,
      completedPhases: completed,
    );
  }

  @override
  Future<void> startAnalysis({
    double? initialGrossArea,
    double? initialUsableArea,
    Duration stepDuration = const Duration(milliseconds: 750),
  }) {
    final completer = Completer<void>();
    final session = SolarSessionState();
    final gross = initialGrossArea ?? session.rooftopAnalysis.totalGrossAreaSqFt;
    final usable = initialUsableArea ?? session.rooftopAnalysis.netUsableAreaSqFt;
    _isFastForwarded = false;

    _stepTimer?.cancel();

    final phases = [
      AnalysisPhase.input,
      AnalysisPhase.analysing,
      AnalysisPhase.rooftopDetected,
      AnalysisPhase.areaEstimated,
      AnalysisPhase.solarPotentialCalculated,
      AnalysisPhase.resultReady,
    ];

    int index = 0;
    final completed = <AnalysisPhase>[];

    late void Function() scheduleNext;

    void runStep() {
      if (_isFastForwarded || _controller.isClosed || index >= phases.length) {
        if (!completer.isCompleted) completer.complete();
        return;
      }
      final currentPhase = phases[index];
      _currentState = _createState(
        phase: currentPhase,
        grossArea: gross,
        usableArea: usable,
        completed: List.from(completed),
      );
      if (!_controller.isClosed) {
        _controller.add(_currentState);
      }
      completed.add(currentPhase);
      index++;

      if (index < phases.length && !_isFastForwarded) {
        scheduleNext();
      } else {
        // Update session state with completed analysis
        session.updateRooftopAnalysis(
          grossAreaSqFt: gross,
          usableAreaSqFt: usable,
        );
        if (!completer.isCompleted) completer.complete();
      }
    }

    scheduleNext = () {
      if (stepDuration == Duration.zero) {
        scheduleMicrotask(runStep);
      } else {
        _stepTimer = Timer(stepDuration, runStep);
      }
    };

    runStep();
    return completer.future;
  }

  @override
  void fastForward() {
    _isFastForwarded = true;
    _stepTimer?.cancel();
    _stepTimer = null;
    _currentState = _createState(
      phase: AnalysisPhase.resultReady,
      grossArea: _currentState.detectedGrossAreaSqFt,
      usableArea: _currentState.usableAreaSqFt,
      completed: AnalysisPhase.values.toList(),
    );
    SolarSessionState().updateRooftopAnalysis(
      grossAreaSqFt: _currentState.detectedGrossAreaSqFt,
      usableAreaSqFt: _currentState.usableAreaSqFt,
    );
    if (!_controller.isClosed) {
      _controller.add(_currentState);
    }
  }

  @override
  void dispose() {
    _isFastForwarded = true;
    _stepTimer?.cancel();
    _stepTimer = null;
    _controller.close();
  }
}
