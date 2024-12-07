import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:mobile/controller/map_controller.dart';
import 'package:mobile/widgets/circle_layer.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final CustomMapController _mapController = CustomMapController();
  Timer? _timer;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startUpdatingLocation();
    _mapController.listenToDeviceChanges();

    _mapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {});
      }
    });
  }

  Future<void> _initializeMap() async {
    await _mapController.getCurrentLocation();
    setState(() {});
  }

  void _startUpdatingLocation() {
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      _mapController.updateLocation(position);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _zoomIn() {
    _mapController.mapController.move(
      _mapController.mapController.center,
      _mapController.mapController.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.mapController.move(
      _mapController.mapController.center,
      _mapController.mapController.zoom - 1,
    );
  }

  void _viewList() {}

  void _moveToCurrentLocation() {
    _mapController.mapController.move(_mapController.currentPosition, 13.0);
  }

  @override
  Widget build(BuildContext context) {
    final circleLayerBuilder = CircleLayerBuilder(
      markers: _mapController.markers,
      mapController: _mapController,
    );
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
            CircleLayer(
              circles: circleLayerBuilder.buildCircles(),
            ),
            MarkerLayer(
              markers: [
                if (_mapController.userLocationMarker != null)
                  _mapController.userLocationMarker!
              ],
            ),
            MarkerLayer(
              markers: [
                ..._mapController.markers,
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _moveToCurrentLocation,
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed: _zoomIn,
                backgroundColor: Colors.white,
                child: const Icon(Icons.zoom_in),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: _zoomOut,
                backgroundColor: Colors.white,
                child: const Icon(Icons.zoom_out),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: FloatingActionButton(
            onPressed: _viewList,
            backgroundColor: Colors.white,
            child: const Icon(Icons.list),
          ),
        ),
      ],
    );
  }
}