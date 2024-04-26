import Flutter
import UIKit
import Foundation
import MapKit


public class NekonataMapPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let factory = NekonataMapFactory(messenger: messenger)
    registrar.register(factory, withId: "nekonata_map")
  }
}


public class NekonataMapFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NekonataMapView(frame: frame, viewId: viewId, messenger: messenger, args: args)
    }
}

public class NekonataMapView: NSObject, FlutterPlatformView {
    private var mapView: MKMapView
    private var channel: FlutterMethodChannel?

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        // Initialize your native view
        mapView = MKMapView(frame: frame)
        super.init()

        // Example of initializing method channel
        channel = FlutterMethodChannel(name: "nekonata_map_\(viewId)", binaryMessenger: messenger)
        channel?.setMethodCallHandler(handle)

        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKStandardMapConfiguration(emphasisStyle: MKStandardMapConfiguration.EmphasisStyle.muted)
        } else {
            mapView.mapType = MKMapType.mutedStandard
        }

        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.isScrollEnabled = false
        mapView.showsUserLocation = false
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.insetsLayoutMarginsFromSafeArea = false

        channel?.invokeMethod("onMapCreated", arguments: nil)
    }

    public func view() -> UIView {
        return mapView
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "update" {
            if let arguments = call.arguments as? [String: Any],
                let heading = arguments["heading"] as? Double,
                let longitudeDelta = arguments["longitudeDelta"] as? Double,
                let latitude = arguments["latitude"] as? Double,
                let longitude = arguments["longitude"] as? Double {
                update(heading: heading, longitudeDelta: longitudeDelta, latitude: latitude, longitude: longitude)
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    private func update(heading: Double, longitudeDelta: Double, latitude: Double, longitude: Double) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(
                latitudeDelta: 0,
                longitudeDelta: longitudeDelta
            )
        )
        mapView.setRegion(region, animated: false)
        mapView.setHeading(heading)

        if (longitudeDelta > 4) {
            mapView.setHeading(0)
            channel?.invokeMethod("onHeadingDisabled", arguments: nil)
        }
    }
}

extension MKMapView {
    func setHeading(_ heading: Double) {
        camera.heading = heading
    }
}
