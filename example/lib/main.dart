import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekonata_map/nekonata_map.dart';
import 'package:nekonata_map_example/services.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            if (Platform.isIOS)
              IconButton(
                icon: const Icon(Icons.apple),
                onPressed: () => _changeTileLayer(const AppleMapTileLayer()),
              ),
            IconButton(
              icon: const Icon(Icons.android),
              onPressed: () => _changeTileLayer(const GoogleMapTileLayer()),
            ),
            IconButton(
              icon: const Icon(Icons.public),
              onPressed: () => _changeTileLayer(const OSMTileLayer()),
            ),
          ],
        ),
        body: const _Map(),
      ),
    );
  }

  void _changeTileLayer(TileLayerWidget widget) {
    ref.read(tileLayerProvider.notifier).changeTileLayer(widget);
  }
}

class _Map extends ConsumerStatefulWidget {
  const _Map();

  @override
  ConsumerState<_Map> createState() => _MapState();
}

class _MapState extends ConsumerState<_Map> with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(vsync: this);

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NekonataMap(
      animatedMapController: _animatedMapController,
      initialCenter: const LatLng(35.6895, 139.6917),
      tileLayer: ref.watch(tileLayerProvider),
    );
  }
}
