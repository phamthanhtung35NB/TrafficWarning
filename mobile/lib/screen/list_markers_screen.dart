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
  bool _isLoading = true;
  String _filterType = 'All'; // 'All', 'Device', 'Report', 'UV'

  @override
  void initState() {
    super.initState();
    _fetchMarkers();
  }

  void _fetchMarkers() async {
    setState(() {
      _isLoading = true;
    });

    List<dynamic> markers = await _controller.fetchMarkers();

    setState(() {
      _markers = markers;
      _isLoading = false;
      _sortMarkers();
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

  List<dynamic> get _filteredMarkers {
    if (_filterType == 'All') return _markers;
    if (_filterType == 'Device') return _markers.where((m) => m.runtimeType == Markerss).toList();
    if (_filterType == 'Report') return _markers.where((m) => m.runtimeType == MarkersReports).toList();
    if (_filterType == 'UV') return _markers.where((m) => m.runtimeType == MarkersUV).toList();
    return _markers;
  }

  Color _getTypeColor(dynamic marker) {
    if (marker.runtimeType == Markerss) return Colors.blue.shade700;
    if (marker.runtimeType == MarkersReports) return Colors.red.shade700;
    return Colors.purple.shade700; // UV
  }

  IconData _getTypeIcon(dynamic marker) {
    if (marker.runtimeType == Markerss) return Icons.devices;
    if (marker.runtimeType == MarkersReports) return Icons.report_problem;
    return Icons.wb_sunny; // UV
  }

  String _getTitle(dynamic marker) {
    if (marker.runtimeType == Markerss) return 'Thiết bị: ${marker.other}';
    if (marker.runtimeType == MarkersReports) return 'Báo cáo: ${marker.noiDung}';
    return 'Chỉ số UV: ${marker.uv}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'Tất cả'),
                const SizedBox(width: 8),
                _buildFilterChip('Device', 'Thiết bị'),
                const SizedBox(width: 8),
                _buildFilterChip('Report', 'Báo cáo'),
                const SizedBox(width: 8),
                _buildFilterChip('UV', 'Chỉ số UV'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMarkers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Không có dữ liệu',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                _fetchMarkers();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filteredMarkers.length,
                itemBuilder: (context, index) {
                  var marker = _filteredMarkers[index];
                  double distance = _controller.calculateDistance(marker);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: _getTypeColor(marker).withOpacity(0.2),
                        child: Icon(_getTypeIcon(marker), color: _getTypeColor(marker)),
                      ),
                      title: Text(
                        _getTitle(marker),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                distance < 1000
                                    ? '${distance.toStringAsFixed(0)} m'
                                    : '${(distance / 1000).toStringAsFixed(2)} km',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      onTap: () {
                        // Hiển thị chi tiết khi bấm vào
                        _showMarkerDetails(context, marker);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          setState(() {
            _sortByDistance = !_sortByDistance;
            _sortMarkers();
          });
        },
        child: Icon(_sortByDistance ? Icons.sort : Icons.sort_by_alpha),
        tooltip: _sortByDistance ? 'Sắp xếp theo khoảng cách' : 'Sắp xếp theo loại',
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    bool isSelected = _filterType == type;

    return FilterChip(
      selected: isSelected,
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue.shade700 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _filterType = type;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade700 : Colors.transparent,
        ),
      ),
    );
  }

  void _showMarkerDetails(BuildContext context, dynamic marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chi tiết',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getTypeColor(marker),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.category, color: _getTypeColor(marker)),
                        title: const Text('Loại'),
                        subtitle: Text(
                          marker.runtimeType == Markerss
                              ? 'Thiết bị'
                              : marker.runtimeType == MarkersReports
                              ? 'Báo cáo'
                              : 'UV',
                          style: TextStyle(color: _getTypeColor(marker)),
                        ),
                      ),
                      if (marker.runtimeType == Markerss)
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Thông tin'),
                          subtitle: Text(marker.other ?? 'Không có thông tin'),
                        ),
                      if (marker.runtimeType == MarkersReports)
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: const Text('Nội dung'),
                          subtitle: Text(marker.noiDung ?? 'Không có nội dung'),
                        ),
                      if (marker.runtimeType == MarkersUV)
                        ListTile(
                          leading: const Icon(Icons.wb_sunny_outlined),
                          title: const Text('Chỉ số UV'),
                          subtitle: Text('${marker.uv}'),
                        ),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: const Text('Vị trí'),
                        subtitle: Text(marker.latitudeLongitude ?? 'Không có vị trí'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.straighten_outlined),
                        title: const Text('Khoảng cách'),
                        subtitle: Text(
                          '${_controller.calculateDistance(marker).toStringAsFixed(2)} m',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('Xem trên bản đồ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getTypeColor(marker),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // Chuyển đến MapScreen và hiển thị marker này
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}