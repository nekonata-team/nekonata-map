import 'package:flutter/foundation.dart';
import 'package:nekonata_map/marker.dart';

class MarkerController extends ValueNotifier<List<LocationContextMarker>> {
  MarkerController([List<LocationContextMarker>? initialValue])
      : super(initialValue ?? []);

  MarkerController.empty() : super([]);

  void markNeedsUpdate() {
    notifyListeners();
  }
}
