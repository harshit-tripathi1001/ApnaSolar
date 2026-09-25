import 'package:flutter/material.dart';

import '../../models/property_location.dart';

/// Available visualization modes for solar rooftop maps.
enum SolarMapMode {
  /// Stylized vector schematic map emphasizing roads, solar zones, and building parcels
  vector,

  /// High-resolution satellite aerial photo layer
  satellite,

  /// 3D perspective tilted view of rooftop
  satellite3d,
}

/// Controller managing state, viewport camera, pins, and layers for the solar map.
class SolarMapController extends ChangeNotifier {
  PropertyLocation _property;
  SolarMapMode _mode;
  double _zoomLevel;
  Offset _pinNormalizedOffset; // (0.0, 0.0) to (1.0, 1.0)
  bool _isLocating;

  SolarMapController({
    PropertyLocation? initialProperty,
    SolarMapMode initialMode = SolarMapMode.vector,
    double initialZoom = 1.0,
    Offset initialPinOffset = const Offset(0.5, 0.51),
  }) : _property = initialProperty ?? PropertyLocation.mockIndiranagar(),
       _mode = initialMode,
       _zoomLevel = initialZoom,
       _pinNormalizedOffset = initialPinOffset,
       _isLocating = false;

  PropertyLocation get property => _property;
  SolarMapMode get mode => _mode;
  double get zoomLevel => _zoomLevel;
  Offset get pinNormalizedOffset => _pinNormalizedOffset;
  bool get isLocating => _isLocating;

  void setProperty(PropertyLocation property) {
    _property = property;
    notifyListeners();
  }

  void setMode(SolarMapMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  void toggleSatellite() {
    setMode(
      _mode == SolarMapMode.vector
          ? SolarMapMode.satellite
          : SolarMapMode.vector,
    );
  }

  void zoomIn() {
    if (_zoomLevel < 2.5) {
      _zoomLevel = (_zoomLevel + 0.25).clamp(0.75, 2.5);
      notifyListeners();
    }
  }

  void zoomOut() {
    if (_zoomLevel > 0.75) {
      _zoomLevel = (_zoomLevel - 0.25).clamp(0.75, 2.5);
      notifyListeners();
    }
  }

  void updatePinPosition(Offset normalizedOffset) {
    _pinNormalizedOffset = Offset(
      normalizedOffset.dx.clamp(0.1, 0.9),
      normalizedOffset.dy.clamp(0.1, 0.9),
    );
    notifyListeners();
  }

  void recenterPin() {
    _pinNormalizedOffset = const Offset(0.5, 0.51);
    notifyListeners();
  }

  void triggerGpsLocate() {
    _isLocating = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 600), () {
      _isLocating = false;
      _pinNormalizedOffset = const Offset(0.5, 0.51);
      _zoomLevel = 1.0;
      notifyListeners();
    });
  }
}

/// Abstract contract for solar map implementations.
/// Real providers (Google Maps SDK, Mapbox, OpenStreetMap) can be implemented
/// by implementing this interface in production.
abstract class SolarMapProvider {
  Widget buildMapWidget({
    required BuildContext context,
    required SolarMapController controller,
    required ValueChanged<Offset> onPinMoved,
  });
}
