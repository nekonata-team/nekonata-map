# nekonata_map Interactive map widget for Flutter

Developed by nekonata.

## Features

[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

- Interactive map experience
- Support for Apple Maps, Google Maps, and OpenStreetMap
- Seamless tile layer switching
- Animations
- Cancellable Tile Provider
- Sorted Markers

## Getting Started

If you want to use Google Maps, you need to set up a Google Maps API key in `AndroidManifest.xml` (for Android) and `AppDelegate.swift` (for iOS). Please refer to the example project and the [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) package documentation for setup instructions.

For Apple Maps and OpenStreetMap, no additional setup is required.

### Android

```xml
<manifest ...>
    <application ...>
        ...
        <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR_API_KEY"/>
        ...

```

### iOS

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Installation

To use this package, add `nekonata_map` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  nekonata_map:
    git:
      url: https://github.com/nekonata-team/nekonata-map.git
      ref: main
```

## Usage

After installing the package, you can import it in your Dart code and start using the `NekonataMapController` and `NekonataMap` widgets.

```dart
import 'package:nekonata_map/nekonata_map.dart';
```

Please refer to the package documentation or example project for detailed usage instructions.

### Marker

You can use `MarkerController` to add or update markers to the map. You can customize the marker appearance by implementing the `LocationContext` interface. See the example project for an example.

```dart
MarkerController(
  [
    LocationContextMarker(
      const ExampleLocationElement(LatLng(35.6895, 139.6917)),
      onTap: () => _animatedMapController.animateTo(
        dest: const LatLng(35.6895, 139.6917),
      ),
    ),
  ],
);

/// Example implementation of `LocationContext` for custom marker appearance
final class ExampleLocationElement extends LocationContext {
  /// Constructor takes a `LatLng` for the marker position
  const ExampleLocationElement(super.latLng);

  /// Override `width` and `height` to set the marker size
  @override
  double? get width => 48;

  @override
  double? get height => 48;

  /// Override `build` to provide a custom widget for the marker
  @override
  Widget build(BuildContext context) {
    // You can use original widget for design
    return const Icon(
      Icons.location_on,
      size: 48,
    );
  }
}
```

## Roadmap / Planned Features

- Marker Grouping (Clustering)
- Performance Optimization
- Offline map support
- Advanced interactions (e.g. gestures, overlays, etc.)
- Enhanced customization options
- Additional tile providers (e.g. MapBox, Bing Maps, HERE Maps, etc.)
  - You can implement your own tile provider by implementing the `TileLayerWidget` abstract class
