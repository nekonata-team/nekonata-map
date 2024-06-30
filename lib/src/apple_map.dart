import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              viewType: 'nekonata_map',
              onPlatformViewCreated: (id) {
                _state = context.findAncestorStateOfType<NekonataMapState>()!;

                _controller = _Controller(
                  id,
                  onHeadingDisabled: () {
                    _state.animatedMapController.mapController.rotate(0);
                  },
                  onMapCreated: () {
                    _subscription = _state.eventStream.listen(_onMapEvent);
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

  late final _channel = MethodChannel('nekonata_map_$id');

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

    final (x, _) = crs.untransform(point.x, point.y, crs.scale(zoom));
    return x * d / SphericalMercator.r;
  }
}
