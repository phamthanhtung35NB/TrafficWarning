import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:mobile/services/firebasedb.dart';
import 'package:mobile/model/markerss.dart';
import 'package:mobile/model/markers_reports.dart';
import 'package:mobile/model/markers_uv.dart';

class ListMarkersController {
  final Firebasedb _firebasedb = Firebasedb();
  LatLng _currentPosition = LatLng(21.038859, 105.785613);

  Future<List<dynamic>> fetchMarkers() async {
    List<dynamic> markers = [];
    Map<String, dynamic> devices = await _firebasedb.fetchDevices();
    Map<String, dynamic> imageReports = await _firebasedb.fetchDevicesReports();
    Map<String, dynamic> uvReports = await _firebasedb.fetchUVReports();

    devices.forEach((key, value) {
      markers.add(Markerss.fromJson(Map<String, dynamic>.from(value)));
    });
    imageReports.forEach((key, value) {
      markers.add(MarkersReports.fromJson(Map<String, dynamic>.from(value)));
    });
    uvReports.forEach((key, value) {
      markers.add(MarkersUV.fromJson(Map<String, dynamic>.from(value)));
    });

    return markers;
  }

  double calculateDistance(dynamic marker) {
    List<String> latLng = marker.latitudeLongitude.split(', ');
    LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
    return _calculateDistance(_currentPosition, markerPosition);
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371000; // Radius of the Earth in meters
    double lat1 = pos1.latitude * pi / 180;
    double lon1 = pos1.longitude * pi / 180;
    double lat2 = pos2.latitude * pi / 180;
    double lon2 = pos2.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }
}