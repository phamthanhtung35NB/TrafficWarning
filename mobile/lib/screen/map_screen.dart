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

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final CustomMapController _mapController = CustomMapController();
  Timer? _timer;
  StreamSubscription<Position>? _positionStreamSubscription;
  late final AnimationController _fabAnimationController;
  bool _isMapInteracted = false;
  bool _showSearchResults = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startUpdatingLocation();
    _mapController.listenToDeviceChanges();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _mapController.mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          _isMapInteracted = true;
        });
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
    _fabAnimationController.dispose();
    _searchController.dispose();
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

  void _viewList() {
    // Animation for transition to list view could be added here
  }

  void _moveToCurrentLocation() {
    _mapController.mapController.move(_mapController.currentPosition, 15.0);
    _fabAnimationController.forward(from: 0.0);
    setState(() {
      _isMapInteracted = false;
    });
  }

  void _toggleSearchResults() {
    setState(() {
      _showSearchResults = !_showSearchResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    final circleLayerBuilder = CircleLayerBuilder(
      markers: _mapController.markers,
      mapController: _mapController,
    );

    return Stack(
      children: [
        // Map Layer
        FlutterMap(
          mapController: _mapController.mapController,
          options: MapOptions(
            center: _mapController.currentPosition,
            zoom: 15.0,
            minZoom: 3.0,
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all,
            enableScrollWheel: true,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.mobile',
              tileProvider: NetworkTileProvider(),
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

        // Search Bar
        // Positioned(
        //   top: 16,
        //   left: 16,
        //   right: 16,
        //   child: Card(
        //     elevation: 4,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         TextField(
        //           controller: _searchController,
        //           decoration: InputDecoration(
        //             hintText: 'Tìm kiếm địa điểm...',
        //             prefixIcon: const Icon(Icons.search, color: Colors.blue),
        //             suffixIcon: IconButton(
        //               icon: Icon(
        //                 _showSearchResults ? Icons.close : Icons.filter_list,
        //                 color: Colors.grey,
        //               ),
        //               onPressed: _toggleSearchResults,
        //             ),
        //             border: InputBorder.none,
        //             contentPadding: const EdgeInsets.symmetric(vertical: 15),
        //           ),
        //         ),
        //         // Search results (can be expanded with actual search functionality)
        //         if (_showSearchResults)
        //           Container(
        //             constraints: BoxConstraints(
        //               maxHeight: MediaQuery.of(context).size.height * 0.3,
        //             ),
        //             decoration: BoxDecoration(
        //               border: Border(
        //                 top: BorderSide(color: Colors.grey.shade300),
        //               ),
        //             ),
        //             child: ListView(
        //               shrinkWrap: true,
        //               padding: EdgeInsets.zero,
        //               children: [
        //                 ListTile(
        //                   leading: const Icon(Icons.history, color: Colors.grey),
        //                   title: const Text('Tìm kiếm gần đây...'),
        //                   onTap: () {},
        //                 ),
        //               ],
        //             ),
        //           ),
        //       ],
        //     ),
        //   ),
        // ),

        // Information panel for location (can be shown when a marker is selected)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Container(
              height: 0, // Set to a value when displaying info
              color: Colors.white,
            ),
          ),
        ),

        // Bottom-right Controls
        Positioned(
          bottom: 100,
          right: 16,
          child: Column(
            children: [
              _buildFloatingButton(
                Icons.zoom_in,
                _zoomIn,
                'zoom_in_button',
                tooltip: 'Phóng to',
              ),
              const SizedBox(height: 8),
              _buildFloatingButton(
                Icons.zoom_out,
                _zoomOut,
                'zoom_out_button',
                tooltip: 'Thu nhỏ',
              ),
            ],
          ),
        ),

        // Current location button
        Positioned(
          bottom: 30,
          right: 16,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_fabAnimationController),
            child: _buildFloatingButton(
              _isMapInteracted ? Icons.my_location : Icons.gps_fixed,
              _moveToCurrentLocation,
              'location_button',
              tooltip: 'Vị trí hiện tại',
              color: Colors.blue,
              iconColor: Colors.white,
            ),
          ),
        ),

        // View list button
        Positioned(
          bottom: 30,
          left: 16,
          child: _buildFloatingButton(
            Icons.list,
            _viewList,
            'list_button',
            tooltip: 'Danh sách',
          ),
        ),

        // Loading indicator
        if (_mapController.currentPosition.latitude == 0)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải bản đồ...'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingButton(
    IconData icon,
    VoidCallback onPressed,
    String heroTag, {
    String? tooltip,
    Color color = Colors.white,
    Color iconColor = Colors.blue,
  }) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: color,
      foregroundColor: iconColor,
      elevation: 4,
      tooltip: tooltip,
      mini: heroTag != 'location_button',
      child: Icon(icon),
    );
  }
}