import 'package:flutter/material.dart';

import 'package:nekonata_map/nekonata_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late final animatedMapController = AnimatedMapController(vsync: this);

  @override
  void dispose() {
    animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: NekonataMap(
          animatedMapController: animatedMapController,
          initialCenter: const LatLng(35.6895, 139.6917),
          // tileLayer: const OSMTileLayer(),
          tileLayer: const AppleMapTileLayer(),
          // tileLayer: const OSMTileLayer(),
        ),
      ),
    );
  }
}
