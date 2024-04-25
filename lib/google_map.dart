import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:latlong2/latlong.dart';
import 'package:nekonata_map/nekonata_map.dart';

class NekonataGoogleMap extends StatefulWidget {
  const NekonataGoogleMap({super.key});

  @override
  State<NekonataGoogleMap> createState() => _NekonataGoogleMapState();
}

class _NekonataGoogleMapState extends State<NekonataGoogleMap> {
  late final google.GoogleMapController _controller;
  StreamSubscription<MapEvent>? _subscription;
  late final NekonataMapState _state;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: google.GoogleMap(
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              indoorViewEnabled: true,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              // trafficEnabled: true,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: false,
              initialCameraPosition: const google.CameraPosition(
                target: google.LatLng(0, 0),
              ),
              onMapCreated: (controller) {
                _controller = controller;
                _state = context.findAncestorStateOfType<NekonataMapState>()!;
                _subscription = _state.mapEventStream.listen(_onMapEvent);
                _onMapEvent(_state.event);
              },
              onCameraMove: (position) {
                // debugPrint(position.toString());
                // debugPrint(_state.event.camera.toGoogleString());
              },
            ),
          ),
          Container(color: Colors.transparent),
        ],
      );

  void _onMapEvent(MapEvent event) {
    _controller.moveCamera(
      google.CameraUpdate.newCameraPosition(event.camera.toGoogle()),
    );
  }
}

extension _ConvertLatLng on LatLng {
  google.LatLng toGoogle() => google.LatLng(latitude, longitude);
}

extension _ConvertCamera on MapCamera {
  google.CameraPosition toGoogle() => google.CameraPosition(
        target: convertLatLng().toGoogle(),
        zoom: zoom,
        bearing: -rotation,
      );

  LatLng convertLatLng() {
    final mapCenterPoint = project(center, zoom);
    final adjustedCenterPoint = Point(mapCenterPoint.x, mapCenterPoint.y);
    final rotatedPoint = rotatePoint(mapCenterPoint, adjustedCenterPoint);

    final rounded = rotatedPoint.round(); // optional
    return unproject(rounded, zoom);
  }
}
