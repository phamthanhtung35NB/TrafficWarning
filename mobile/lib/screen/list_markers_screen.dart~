import 'package:flutter/material.dart';
import 'package:mobile/controller/list_markers_controller.dart';
import 'package:mobile/model/markerss.dart';
import 'package:mobile/model/markers_reports.dart';
import 'package:mobile/model/markers_uv.dart';

class ListMarkersScreen extends StatefulWidget {
  @override
  _ListMarkersScreenState createState() => _ListMarkersScreenState();
}

class _ListMarkersScreenState extends State<ListMarkersScreen> {
  final ListMarkersController _controller = ListMarkersController();
  List<dynamic> _markers = [];
  bool _sortByDistance = true;

  @override
  void initState() {
    super.initState();
    _fetchMarkers();
  }

  void _fetchMarkers() async {
    List<dynamic> markers = await _controller.fetchMarkers();
    setState(() {
      _markers = markers;
    });
  }

  void _sortMarkers() {
    setState(() {
      if (_sortByDistance) {
        _markers.sort((a, b) => _controller.calculateDistance(a).compareTo(_controller.calculateDistance(b)));
      } else {
        _markers.sort((a, b) {
          int typeComparison = a.runtimeType.toString().compareTo(b.runtimeType.toString());
          if (typeComparison != 0) return typeComparison;
          return _controller.calculateDistance(a).compareTo(_controller.calculateDistance(b));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách các đối tượng'),
        actions: [
          IconButton(
            icon: Icon(_sortByDistance ? Icons.sort_by_alpha : Icons.sort),
            onPressed: () {
              setState(() {
                _sortByDistance = !_sortByDistance;
                _sortMarkers();
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _markers.length,
        itemBuilder: (context, index) {
          var marker = _markers[index];
          return ListTile(
            title: Text(marker.runtimeType == Markerss
                ? 'Thiết bị: ${marker.other}'
                : marker.runtimeType == MarkersReports
                ? 'Báo cáo: ${marker.noiDung}'
                : 'UV: ${marker.uv}'),
            subtitle: Text('Khoảng cách: ${_controller.calculateDistance(marker).toStringAsFixed(2)} m'),
          );
        },
      ),
    );
  }
}