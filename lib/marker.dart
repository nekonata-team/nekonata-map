import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nekonata_map/bouncing_scale_animation_on_tap.dart';
import 'package:nekonata_map/location_context.dart';

///LocationContextをもとにMarkerのプロパティを設定する
///また、onTapのプロパティを設定できるようにしている
class LocationContextMarker extends Marker {
  LocationContextMarker(
    LocationContext locationContext, {
    VoidCallback? onTap,
  }) : this._animated(
          locationContext,
          scale: const AlwaysStoppedAnimation(1),
          onTap: onTap,
        );

  LocationContextMarker._animated(
    this.locationContext, {
    required Animation<double> scale,
    this.onTap,
  }) : super(
          point: locationContext.latLng,
          width: locationContext.width ?? 30, // same [Marker.width] default
          height: locationContext.height ?? 30, // same [Marker.height] default
          alignment: Alignment.topCenter,
          child: BouncingScaleAnimationOnTap(
            onTap: onTap,
            alignment: Alignment.bottomCenter,
            child: HookBuilder(
              builder: (BuildContext context) => ScaleTransition(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: locationContext.build(context),
              ),
            ),
          ),
          rotate: true,
        );

  final LocationContext locationContext;
  final VoidCallback? onTap;

  @override
  String toString() => 'LocationContextMarker($locationContext)';

  LocationContextMarker attachAnimation(Animation<double> scale) {
    return LocationContextMarker._animated(
      locationContext,
      scale: scale,
      onTap: onTap,
    );
  }
}
