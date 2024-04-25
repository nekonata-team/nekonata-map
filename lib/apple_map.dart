import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nekonata_map/nekonata_map.dart';

class NekonataAppleMap extends StatefulWidget {
  const NekonataAppleMap({super.key});

  @override
  State<NekonataAppleMap> createState() => _NekonataAppleMapState();
}

class _NekonataAppleMapState extends State<NekonataAppleMap> {
  late final _Controller _controller;
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
            child: UiKitView(
              viewType: 'nekonata/apple_map_view',
              onPlatformViewCreated: (id) {
                _state = context.findAncestorStateOfType<NekonataMapState>()!;

                _controller = _Controller(
                  id,
                  onHeadingDisabled: () {
                    _state.animatedMapController.mapController.rotate(0);
                  },
                  onMapCreated: () {
                    _subscription = _state.mapEventStream.listen(_onMapEvent);
                    _onMapEvent(_state.event);
                  },
                );
              },
            ),
          ),
          Container(color: Colors.transparent),
        ],
      );

  void _onMapEvent(MapEvent event) {
    _controller.update(event.camera);
  }
}

class _Controller {
  _Controller(
    this.id, {
    VoidCallback? onHeadingDisabled,
    VoidCallback? onMapCreated,
  }) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onHeadingDisabled':
          // debugPrint('onHeadingDisabled');
          onHeadingDisabled?.call();
        case 'onMapCreated':
          // debugPrint('onMapCreated');
          onMapCreated?.call();
        default:
          throw UnimplementedError(call.method);
      }
    });
  }
  final int id;

  late final _channel = MethodChannel('nekonata/apple_map_controller_$id');

  Future<void> update(MapCamera camera) {
    return _channel.invokeMethod<void>('update', {
      'longitudeDelta': camera.longitudeDelta,
      'heading': -camera.rotation,
      'longitude': camera.center.longitude,
      'latitude': camera.center.latitude,
    });
  }
}

extension _LongitudeDelta on MapCamera {
  double get longitudeDelta {
    final left = _longitudeFromPoint(const Point(0, 0));
    final right = _longitudeFromPoint(Point(nonRotatedSize.x, 0));
    final delta = (left - right).abs();

    return delta;
  }

  double _longitudeFromPoint(Point localPoint) {
    final localPointCenterDistance = Point(
      (nonRotatedSize.x / 2) - localPoint.x,
      (nonRotatedSize.y / 2) - localPoint.y,
    );
    final mapCenter = crs.latLngToPoint(center, zoom);

    final point = mapCenter - localPointCenterDistance;

    const d = 180 / pi;

    final p = crs.transformation.untransform(point, crs.scale(zoom));
    return p.x * d / SphericalMercator.r;
  }
}

// import 'package:apple_maps_flutter/apple_maps_flutter.dart' as apple;
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// import '../../../types/callbacks.dart';
// import '../map.dart';

// class NekonataAppleMap extends StatefulWidget {
//   const NekonataAppleMap({super.key});

//   @override
//   State<NekonataAppleMap> createState() => _NekonataAppleMapState();
// }

// class _NekonataAppleMapState extends State<NekonataAppleMap> {
//   late final apple.AppleMapController _controller;
//   OneArgumentCallbacks<MapEvent>? _callbacks;
//   late final NekonataMapState _state;

//   @override
//   void dispose() {
//     _callbacks?.unregister(_onMapEvent);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => Stack(
//         alignment: Alignment.center,
//         children: [
//           IgnorePointer(
//             child: apple.AppleMap(
//               initialCameraPosition: const apple.CameraPosition(
//                 target: apple.LatLng(0, 0),
//               ),
//               // mapType: apple.MapType.standard,
//               onMapCreated: (controller) {
//                 _controller = controller;
//                 _state = context.findAncestorStateOfType<NekonataMapState>()!;
//                 _callbacks = _state.onMapEvent;
//                 _callbacks?.register(_onMapEvent);
//                 _onMapEvent(_state.event);
//               },
//               onCameraMove: (position) async {
//                 ///ある程度のズームレベルになるとbearingが0になってしまう。
//                 ///強引にFlutterMapに通知し、同期させる
//                 // debugPrint(position.toString());
//                 // debugPrint(_state.event.camera.toAppleString());
//                 // debugPrint(
//                 //     await _controller.getZoomLevel().then((value) => value.toString()));
//               },
//               // compassEnabled: false,
//               rotateGesturesEnabled: false,
//               scrollGesturesEnabled: false,
//               zoomGesturesEnabled: false,
//               pitchGesturesEnabled: false,
//             ),
//           ),
//           Container(color: Colors.transparent),
//         ],
//       );

//   void _onMapEvent(MapEvent event) {
//     // debugPrint('notified ${event.camera.toStringAppleFormat()}');
//     _controller.moveCamera(
//         apple.CameraUpdate.newCameraPosition(event.camera.toApple()));
//   }
// }

// extension _ConvertLatLng on LatLng {
//   apple.LatLng toApple() => apple.LatLng(latitude, longitude);
// }

// extension _ConvertCamera on MapCamera {
//   /// OSM:
//   /// https://wiki.openstreetmap.org/wiki/Zoom_levels
//   ///
//   /// Apple:
//   /// The zoom level of the camera.
//   ///
//   /// A zoom of 0.0, the default, means the screen width of the world is 256.
//   /// Adding 1.0 to the zoom level doubles the screen width of the map. So at
//   /// zoom level 3.0, the screen width of the world is 2³x256=2048.
//   ///
//   /// Larger zoom levels thus means the camera is placed closer to the surface
//   /// of the Earth, revealing more detail in a narrower geographical region.
//   ///
//   /// The supported zoom level range depends on the map data and device. Values
//   /// beyond the supported range are allowed, but on applying them to a map they
//   /// will be silently clamped to the supported range.

//   apple.CameraPosition toApple() => apple.CameraPosition(
//         target: center.toApple(),
//         zoom: zoom,
//         heading: -rotation,
//         // pitch: -30,
//       );
// }
