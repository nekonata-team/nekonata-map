import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:nekonata_map/src/gesture/map_swipe_zoom.dart';
import 'package:nekonata_map/src/layer.dart';
import 'package:nekonata_map/src/marker_controller.dart';

typedef OnRotateEnd = void Function(double radian);
typedef OnZoomEnd = void Function(double zoom);

final class NekonataMapAnimationData {
  const NekonataMapAnimationData({
    this.scaleCurve = Curves.easeInOutCubic,
    this.interactionEndDetectionThreshold = Durations.medium3,
    this.scaleAnimationDuration = Durations.long1,
  });

  final Curve scaleCurve;
  final Duration interactionEndDetectionThreshold;
  final Duration scaleAnimationDuration;
}

class NekonataMap extends StatefulHookWidget {
  const NekonataMap({
    required this.animatedMapController,
    required this.initialCenter,
    required this.tileLayer,
    super.key,
    this.initialZoom,
    this.minZoom,
    this.maxZoom,
    this.cameraConstraint,
    this.onTap,
    this.onZoomEnd,
    this.onRotateEnd,
    this.onMapReady,
    this.onMapEvent,
    this.actionChildren,
    this.children,
    this.markerController,
    this.attributionAlignment = AttributionAlignment.bottomLeft,
    this.animationData = const NekonataMapAnimationData(),
  });

  final AnimatedMapController animatedMapController;
  final LatLng initialCenter;
  final TileLayerWidget tileLayer;
  final double? initialZoom;
  final double? minZoom;
  final double? maxZoom;
  final CameraConstraint? cameraConstraint;
  final TapCallback? onTap;
  final OnZoomEnd? onZoomEnd;
  final OnRotateEnd? onRotateEnd;
  final VoidCallback? onMapReady;
  final MapEventCallback? onMapEvent;
  final List<Widget>? children;
  final List<Widget>? actionChildren;
  final MarkerController? markerController;
  final AttributionAlignment attributionAlignment;
  final NekonataMapAnimationData animationData;

  @override
  State<NekonataMap> createState() => NekonataMapState();
}

class NekonataMapState extends State<NekonataMap> {
  late var _tileLayer = widget.tileLayer;
  late final _animationData = widget.animationData;

  double? _zoom;
  Timer? _onZoomEndTimer;
  Timer? _onRotationEndTimer;

  Stream<MapEvent> get eventStream =>
      animatedMapController.mapController.mapEventStream;

  MarkerController? _defaultMarkerController;
  MarkerController get markerController =>
      widget.markerController ??
      (_defaultMarkerController = MarkerController.empty());

  AnimatedMapController get animatedMapController =>
      widget.animatedMapController;

  MapEvent get event =>
      MapEventCustom(camera: animatedMapController.mapController.camera);

  @override
  void didUpdateWidget(covariant NekonataMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tileLayer != oldWidget.tileLayer) {
      setState(() {
        _tileLayer = widget.tileLayer;
      });
    }
  }

  @override
  void dispose() {
    _onZoomEndTimer?.cancel();
    _onRotationEndTimer?.cancel();
    _defaultMarkerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.children?.every((element) => element is! MarkerLayer) ?? true,
      'Markers should be display by using markers property',
    );
    final scaleAnimationController = useAnimationController(
      duration: _animationData.scaleAnimationDuration,
    );

    useEffect(
      () {
        scaleAnimationController.forward();
        return null;
      },
      const [],
    );

    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        FlutterMap(
          mapController: animatedMapController.mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom ?? 12.0,
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            cameraConstraint: widget.cameraConstraint,
            onTap: widget.onTap,
            onMapReady: widget.onMapReady,
            onPositionChanged: (position, hasGesture) {
              if (position.zoom case final double zoom) {
                _checkZoomEnd(zoom);
                if (zoom < 8) {
                  scaleAnimationController.animateBack(
                    0.8,
                    curve: _animationData.scaleCurve,
                  );
                } else {
                  scaleAnimationController.animateTo(
                    1,
                    curve: _animationData.scaleCurve,
                  );
                }
              }
              // debugPrint(position.toString());
            },
            onMapEvent: (event) {
              widget.onMapEvent?.call(event);

              if (event is MapEventRotate) {
                _checkRotationEnd(event);
              }
            },
            // interactionOptions: const InteractionOptions(
            //   flags: InteractiveFlag.all & ~InteractiveFlag.flingAnimation,
            // ),
          ),
          children: [
            Opacity(opacity: _tileLayer.opacity, child: _tileLayer),
            _MarkerLayer(
              markerController: markerController,
              animatedMapController: animatedMapController,
              scaleAnimationController: scaleAnimationController,
            ),
            ...?widget.children,
            _tileLayer.buildAttribution(context, widget.attributionAlignment),
          ],
        ),
        Positioned(
          right: 0,
          child: MapSwipeZoom(
            animatedMapController: animatedMapController,
          ),
        ),
        Positioned(
          left: 0,
          child: MapSwipeZoom(
            animatedMapController: animatedMapController,
          ),
        ),
        ...?widget.actionChildren,
      ],
    );
  }

  void _checkZoomEnd(double newZoom) {
    if (_zoom case final double zoom when newZoom != zoom) {
      _onZoomEndTimer?.cancel();
      _onZoomEndTimer = Timer(
        _animationData.interactionEndDetectionThreshold,
        () => widget.onZoomEnd?.call(zoom),
      );
    } else {
      _zoom = newZoom;
    }
  }

  void _checkRotationEnd(MapEventRotate event) {
    _onRotationEndTimer?.cancel();
    _onRotationEndTimer = Timer(
      _animationData.interactionEndDetectionThreshold,
      () => widget.onRotateEnd?.call(event.camera.rotationRad),
    );
  }
}

class _MarkerLayer extends StatelessWidget {
  const _MarkerLayer({
    required this.markerController,
    required this.animatedMapController,
    required this.scaleAnimationController,
  });

  final MarkerController markerController;
  final AnimatedMapController animatedMapController;
  final AnimationController scaleAnimationController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: markerController,
      builder: (context, value, _) {
        final camera = animatedMapController.mapController.camera;

        final markers = value
            .map((e) => e.attachAnimation(scaleAnimationController))
            .toList();

        return MarkerLayer(
          markers: markers.length <= 1
              ? markers
              : markers
                  .map((e) => (e, e.priority(camera)))
                  .sorted((a, b) => a.$2.compareTo(b.$2))
                  .map((e) => e.$1)
                  .toList(),
        );
      },
    );
  }
}

extension _Priority on Marker {
  double priority(MapCamera camera) {
    final radian = camera.rotationRad;
    final coord = camera.project(point);
    final rotatedY = cos(radian) * coord.y + sin(radian) * coord.x;
    // debugPrint(rotatedY.toString());

    return rotatedY;
  }
}

@immutable
final class MapEventCustom extends MapEvent {
  const MapEventCustom({required super.camera})
      : super(source: MapEventSource.custom);
}
