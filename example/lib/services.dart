import 'package:nekonata_map/nekonata_map.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'services.g.dart';

@riverpod
class TileLayer extends _$TileLayer {
  @override
  TileLayerWidget build() {
    return const OSMTileLayer();
  }

  // ignore: use_setters_to_change_properties
  void changeTileLayer(TileLayerWidget widget) {
    state = widget;
  }
}
