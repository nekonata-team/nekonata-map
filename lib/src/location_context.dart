import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

///Markerに設定するプロパティを委譲するクラス。LocationContextMarkerに渡す
///Markerに共通のプロパティがある場合に、Markerクラスを継承して実装するより柔軟性がある
///また、注力する部分を絞って実装できる。buildメソッドの実装は必須
abstract class LocationContext {
  const LocationContext(this.latLng);

  final LatLng latLng;

  double? get width => 60;
  double? get height => 60;

  Widget build(BuildContext context);
}
