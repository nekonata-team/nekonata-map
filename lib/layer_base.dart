import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
// import 'package:vector_map_tiles/vector_map_tiles.dart';

import 'layer.dart';

abstract class UrlBaseTileLayer extends TileLayerWidget {
  const UrlBaseTileLayer({
    super.key,
    required this.urlTemplate,
    String? darkUrlTemplate,
  }) : darkUrlTemplate = darkUrlTemplate ?? urlTemplate;

  final String urlTemplate;
  final String darkUrlTemplate;

  @override
  Widget build(BuildContext context) {
    // get theme from context
    final brightness = Theme.of(context).brightness;
    ;
    return TileLayer(
      urlTemplate:
          brightness == Brightness.dark ? darkUrlTemplate : urlTemplate,
      userAgentPackageName: 'com.app.nekonata',
      tileProvider: CancellableNetworkTileProvider(),
      errorImage: const AssetImage('assets/images/map_tile_on_error.jpeg'),
    );
  }
}

// abstract class UrlBaseVectorTileLayer extends TileLayerWidget {
//   const UrlBaseVectorTileLayer({
//     super.key,
//     required this.urlTemplate,
//     String? darkUrlTemplate,
//     this.tileOffset,
//     this.apiKey,
//   }) : darkUrlTemplate = darkUrlTemplate ?? urlTemplate;

//   final String urlTemplate;
//   final String darkUrlTemplate;
//   final TileOffset? tileOffset;
//   final String? apiKey;

//   @override
//   Widget build(BuildContext context) => FutureBuilder(
//         future: StyleReader(
//           uri: NekoAPI.setting.local.brightness == Brightness.dark
//               ? darkUrlTemplate
//               : urlTemplate,
//           apiKey: apiKey,
//         ).read(),
//         builder: (_, snapshot) {
//           if (!snapshot.hasData) return const SizedBox();
//           final style = snapshot.requireData;
//           return VectorTileLayer(
//             tileProviders: style.providers,
//             theme: style.theme,
//             sprites: style.sprites,
//             maximumZoom: kMapMaxZoom,
//             tileOffset: tileOffset ?? TileOffset.DEFAULT,
//             layerMode: VectorTileLayerMode.vector,
//           );
//         },
//       );
// }
