import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/controller/map_controller.dart';

class CircleLayerBuilder {
  final List<Marker> markers;
  final CustomMapController mmapController;

  CircleLayerBuilder({required this.markers, required CustomMapController mapController}) : mmapController = mapController;
  List<CircleMarker> buildCircles() {
    return markers.map((marker) {
      // Lấy zoom level hiện tại
      final currentZoom = mmapController.mapController.zoom;

      // Tính toán radius dựa trên zoom level
      // 1000 meters = 1km là bán kính thực tế mong muốn
      final metersPerPixel = 156543.03392 *
          cos(marker.point.latitude * pi / 180) /
          pow(2, currentZoom);
      final radiusInPixels = 1000 / metersPerPixel;

      return CircleMarker(
        point: marker.point,
        color: Colors.blue.withOpacity(0.0),
        borderStrokeWidth: 2,
        borderColor: Colors.blue,
        radius: radiusInPixels, // Sử dụng bán kính đã được tính toán
      );
    }).toList();
  }

}