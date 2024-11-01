import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/controller/home_controller.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _homeController = HomeController();
  List<Marker> _markers = [];
  LatLng _currentPosition = LatLng(21.038859, 105.785613); // Vị trí mặc định

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchMarkers();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _currentPosition,
          builder: (ctx) => const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
        ),
      );
    });
  }

  Future<void> _fetchMarkers() async {
    Map<String, dynamic> devices = await _homeController.fetchDevices();
    List<Marker> markers = [];
    devices.forEach((key, value) {
      if (key != 'sumDevices') {
        List<String> latLng = (value['latitudeLongitude'] as String).split(', ');
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(double.parse(latLng[0]), double.parse(latLng[1])),
            builder: (ctx) => GestureDetector(
              onTap: () => _showDeviceInfo(value['level'], value['other']),
              child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
            ),
          ),
        );
      }
    });
    setState(() {
      _markers.addAll(markers);
    });
  }

  void _showDeviceInfo(int level, String other) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: _currentPosition,
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}