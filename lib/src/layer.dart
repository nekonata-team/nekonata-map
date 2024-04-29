import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nekonata_map/nekonata_map.dart';
// import 'package:vector_map_tiles/vector_map_tiles.dart';

import 'package:nekonata_map/src/apple_map.dart';
import 'package:nekonata_map/src/google_map.dart';
import 'package:nekonata_map/src/layer_base.dart';
import 'package:url_launcher/url_launcher_string.dart';

abstract class TileLayerWidget extends StatelessWidget {
  const TileLayerWidget({super.key});

  double get opacity => 1;

  Widget buildAttribution(
    BuildContext context,
    AttributionAlignment alignment,
  ) =>
      const SizedBox();
}

class MockTileLayer extends TileLayerWidget {
  const MockTileLayer({super.key});

  @override
  Widget build(BuildContext context) => const Placeholder();
}

class OSMTileLayer extends UrlBaseTileLayer {
  const OSMTileLayer({super.key})
      : super(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');

  @override
  double get opacity => 0.75;

  @override
  Widget buildAttribution(
    BuildContext context,
    AttributionAlignment alignment,
  ) =>
      RichAttributionWidget(
        alignment: alignment,
        attributions: [
          TextSourceAttribution(
            'OpenStreetMap contributors',
            onTap: () =>
                launchUrlString('http://www.openstreetmap.org/copyright'),
          ),
        ],
      );
}

// abstract class MapboxBaseTileLayer extends UrlBaseVectorTileLayer {
//   const MapboxBaseTileLayer({
//     super.key,
//     required super.urlTemplate,
//     super.darkUrlTemplate,
//   }) : super(
//             apiKey:
//                 'pk.eyJ1IjoidHlwaG9vbjA4MjkiLCJhIjoiY2x0azB2YTZuMHczZTJtcG44aGxtMzN3cSJ9.bLMJDwOY0kPmcoG2B8wAUQ');

//   @override
//   TileOffset? get tileOffset => TileOffset.mapbox;

//   @override
//   Widget buildAttribution(
//     BuildContext context,
//     AttributionAlignment alignment,
//   ) =>
//       RichAttributionWidget(
//         alignment: alignment,
//         attributions: [
//           TextSourceAttribution(
//             'Mapbox',
//             onTap: () => launchUrlString('https://www.mapbox.com/about/maps/'),
//           ),
//           TextSourceAttribution(
//             'OpenStreetMap',
//             onTap: () =>
//                 launchUrlString('http://www.openstreetmap.org/copyright'),
//           ),
//           TextSourceAttribution(
//             'Improve this map',
//             onTap: () =>
//                 launchUrlString('https://www.mapbox.com/map-feedback/'),
//           ),
//         ],
//       );
// }

// // https://docs.mapbox.com/api/maps/styles/
// enum MapboxStyle {
//   dark('dark-v11'),
//   light('light-v11'),
//   streets('streets-v8');

//   const MapboxStyle(this.name);

//   final String name;

//   String buildUrl() => 'mapbox://styles/mapbox/$name?access_token={key}';
// }

// class MapboxThemeAdaptableTileLayer extends MapboxBaseTileLayer {
//   MapboxThemeAdaptableTileLayer({super.key})
//       : super(
//           urlTemplate: MapboxStyle.light.buildUrl(),
//           darkUrlTemplate: MapboxStyle.dark.buildUrl(),
//         );
// }

// class MapboxTileLayer extends MapboxBaseTileLayer {
//   MapboxTileLayer({super.key})
//       : super(urlTemplate: MapboxStyle.streets.buildUrl());
// }

class AppleMapTileLayer extends TileLayerWidget {
  const AppleMapTileLayer({super.key});

  @override
  double get opacity => 0.85;

  @override
  Widget build(BuildContext context) => const NekonataAppleMap();

  @override
  Widget buildAttribution(
    BuildContext context,
    AttributionAlignment alignment,
  ) =>
      RichAttributionWidget(
        showFlutterMapAttribution: false,
        alignment: alignment,
        attributions: [
          TextSourceAttribution(
            'Apple Map Legal',
            onTap: () => launchUrlString(
              'https://gspe21-ssl.ls.apple.com/html/attribution-275.html',
            ),
          ),
        ],
      );
}

class GoogleMapTileLayer extends TileLayerWidget {
  const GoogleMapTileLayer({super.key});

  @override
  double get opacity => 0.66;

  @override
  Widget build(BuildContext context) => const NekonataGoogleMap();

  @override
  Widget buildAttribution(
    BuildContext context,
    AttributionAlignment alignment,
  ) =>
      RichAttributionWidget(
        showFlutterMapAttribution: false,
        alignment: alignment,
        attributions: [
          TextSourceAttribution(
            'Google Map',
            onTap: () async {
              final state =
                  context.findAncestorStateOfType<NekonataMapState>()!;
              final event = state.event;
              final camera = event.camera;
              final center = camera.center;
              await launchUrlString(
                'https://www.google.com/maps?ll=${center.latitude},${center.longitude}&t=m&z=${camera.zoom}',
              );
            },
          ),
        ],
      );
}

class PlatformMapTileLayer extends TileLayerWidget {
  const PlatformMapTileLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      Platform.isIOS ? const AppleMapTileLayer() : const GoogleMapTileLayer();
}
