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
    if(uvReport.uv<3 && uvReport.uv>=0){
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
      ),
      child: Icon(
        Icons.wb_sunny,
        color: Colors.white,
        size: 30.0,
      ),
    );
    } else if(3<=uvReport.uv&& uvReport.uv<8){
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amberAccent,
        ),
        child: Icon(
          Icons.wb_sunny,
          color: Colors.white,
          size: 30.0,
        ),
      );
    } else if(8<=uvReport.uv && uvReport.uv <11)
      { return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Icon(
          Icons.wb_sunny,
          color: Colors.white,
          size: 30.0,
        ),

      );
      } else if(uvReport.uv >=11) {
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
    return SizedBox.shrink();
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