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
    const double earthRadius = 6371; // Earth radius in kilometers
    double dLat = _degreesToRadians(pos2.latitude - pos1.latitude);
    double dLon = _degreesToRadians(pos2.longitude - pos1.longitude);
    double a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(pos1.latitude)) * cos(_degreesToRadians(pos2.latitude)) *
      sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Icon getIcon(Markerss marker) {
    List<String> latLng = marker.latitudeLongitude.split(', ');
    LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
    double distance = _calculateDistance(currentPosition, markerPosition);

    if (marker.level == 1) {
      return Icon(Icons.location_on, color: Colors.blue, size: 40.0);
    } else if (marker.level == 2) {
      return Icon(Icons.location_on, color: Colors.orange, size: 40.0);
    } else {
      if (distance <= 1.0) {
        return Icon(Icons.location_on, color: Colors.black, size: 40.0);
      } else {
        return Icon(Icons.location_on, color: Colors.red, size: 40.0);
      }
    }
  }
}