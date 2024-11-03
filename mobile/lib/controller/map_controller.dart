// File: lib/controller/map_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/controller/home_controller.dart';

class CustomMapController {
  List<Marker> markers = [];
  LatLng currentPosition = LatLng(21.038859, 105.785613);
  final HomeController homeController = HomeController();

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Dịch vụ định vị đã bị vô hiệu hóa.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Quyền vị trí bị từ chối');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Quyền truy cập vị trí bị từ chối vĩnh viễn, chúng tôi không thể yêu cầu cấp quyền.');
    }

    Position position = await Geolocator.getCurrentPosition();
    currentPosition = LatLng(position.latitude, position.longitude);
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: currentPosition,
        builder: (ctx) => const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
      ),
    );
  }

  Future<void> fetchMarkers() async {
    Map<String, dynamic> devices = await homeController.fetchDevices();
    List<Marker> newMarkers = [];
    devices.forEach((key, value) {
      if (key != 'sumDevices') {
        List<String> latLng = (value['latitudeLongitude'] as String).split(', ');
        newMarkers.add(
          Marker(
            width: 50.0,
            height: 50.0,
            point: LatLng(double.parse(latLng[0]), double.parse(latLng[1])),
            builder: (ctx) => GestureDetector(
              onTap: () => _showDeviceInfo(ctx, value['level'], value['other']),
              child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
            ),
          ),
        );
      }
    });
    markers.addAll(newMarkers);
  }

  void _showDeviceInfo(BuildContext context, int level, String other) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Device Info'),
          content: Text('Level: $level\nOther: $other'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}