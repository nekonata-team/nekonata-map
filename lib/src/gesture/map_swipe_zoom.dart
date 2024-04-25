import 'package:flutter/widgets.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

class MapSwipeZoom extends StatelessWidget {
  const MapSwipeZoom({
    required AnimatedMapController animatedMapController,
    super.key,
  }) : _animatedMapController = animatedMapController;

  final AnimatedMapController _animatedMapController;

  @override
  Widget build(BuildContext context) {
    var zoomFlag = false;
    var currentZoom = 16.0;
    var newZoom = 16.0;
    var startingPositionY = 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragStart: (details) {
        if (details.localPosition.dx < MediaQuery.of(context).size.width / 8 ||
            details.localPosition.dx >
                MediaQuery.of(context).size.width * 7 / 8) {
          zoomFlag = true;
          currentZoom = _animatedMapController.mapController.camera.zoom;
          startingPositionY = details.localPosition.dy;
        }
      },
      onVerticalDragUpdate: (details) {
        if (zoomFlag == true) {
          final currentPositionY = details.localPosition.dy;
          final difference = startingPositionY - currentPositionY;
          final height = MediaQuery.of(context).size.height;
          final scaleFactor = 1.0 + (2 * difference / height);
          newZoom = currentZoom * scaleFactor;
          if (newZoom >= 2 && newZoom <= 18) {
            _animatedMapController.mapController.move(
              _animatedMapController.mapController.camera.center,
              newZoom,
            );
          }
        }
      },
      onVerticalDragEnd: (details) {
        if (zoomFlag == true) {
          zoomFlag = false;
        }
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width / 8,
      ),
    );
  }
}
