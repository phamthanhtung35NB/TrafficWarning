import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/model/markerss.dart';

class IconMarkersCustomDrawer extends StatelessWidget {
  final LatLng currentPosition;

  const IconMarkersCustomDrawer({super.key, required this.currentPosition});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371000; // Bán kính Trái đất theo mét
    double lat1 = pos1.latitude * pi / 180; // Chuyển vĩ độ từ độ sang radian
    double lon1 = pos1.longitude * pi / 180; // Chuyển kinh độ từ độ sang radian
    double lat2 = pos2.latitude * pi / 180;
    double lon2 = pos2.longitude * pi / 180;

    double dLat = lat2 - lat1; // Chênh lệch vĩ độ
    double dLon = lon2 - lon1; // Chênh lệch kinh độ

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c; // Khoảng cách theo mét
    return distance;
  }

  Icon getIcon(Markerss marker) {
    List<String> latLng = marker.latitudeLongitude.split(', ');
    LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
    double distance = _calculateDistance(currentPosition, markerPosition);
    print(distance);
    if (marker.level == 1) {
      return Icon(Icons.location_on, color: Colors.blue, size: 40.0);
    } else if (marker.level == 2) {
      return Icon(Icons.location_on, color: Colors.orange, size: 40.0);
    } else {
      if (distance <= 1000) {
        return Icon(Icons.location_on, color: Colors.black, size: 40.0);
      } else {
        return Icon(Icons.location_on, color: Colors.red, size: 40.0);
      }
    }
  }
}