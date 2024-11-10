import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'package:mobile/controller/map_controller.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final CustomMapController _mapController = CustomMapController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startUpdatingLocation();
    _mapController.listenToDeviceChanges();

    // Thêm listener cho zoom
    _mapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {}); // Cập nhật UI khi zoom thay đổi
      }
    });
  }

  Future<void> _initializeMap() async {
    await _mapController.getCurrentLocation();
    setState(() {});
  }

  void _startUpdatingLocation() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      await _mapController.getCurrentLocation();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _moveToCurrentLocation() {
    _mapController.mapController.move(_mapController.currentPosition, 13.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController.mapController,
          options: MapOptions(
            center: _mapController.currentPosition,
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                if (_mapController.userLocationMarker != null)
                  _mapController.userLocationMarker!,
                ..._mapController.markers,
              ],
            ),
            CircleLayer(
              circles: _mapController.markers.map((marker) {
                // Lấy zoom level hiện tại
                final currentZoom = _mapController.mapController.zoom;

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
              }).toList(),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _moveToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
