import 'package:flutter/material.dart';
import '../model/markers_uv.dart';

class UVMarker extends StatelessWidget {
  final MarkersUV uvReport;

  UVMarker({required this.uvReport});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showUVReportInfo(context),
      child: _buildUVReportIcon(),
    );
  }

  Widget _buildUVReportIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple,
      ),
      child: Icon(
        Icons.wb_sunny,
        color: Colors.white,
        size: 30.0,
      ),
    );
  }

  void _showUVReportInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông tin UV'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chỉ số UV: ${uvReport.uv}'),
              Text('Vị trí: ${uvReport.latitudeLongitude}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}