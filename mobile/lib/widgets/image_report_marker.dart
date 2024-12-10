import 'package:flutter/material.dart';
import '../model/markers_reports.dart';

class ImageReportMarker extends StatelessWidget {
  final MarkersReports report;

  ImageReportMarker({required this.report});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageReportInfo(context),
      child: _buildImageReportIcon(),
    );
  }

  Widget _buildImageReportIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      child: Icon(
        Icons.warning,
        color: Colors.white,
        size: 30.0,
      ),
    );
  }

  void _showImageReportInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Thông tin người dùng gửi báo cáo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Vị trí', report.latitudeLongitude),
                _buildInfoRow('Loại sự cố', report.loaiSuCo),
                // Image display section
                SizedBox(height: 10),
                Text(
                  'Hình ảnh',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                _buildImageRow(report.hinhAnh1, report.hinhAnh2),
                _buildInfoRow('Nội dung', report.noiDung),
                _buildInfoRow('Hiệu lực', report.hieuLuc.toString()),
                _buildInfoRow('Người gửi', report.hoVaTen),
                _buildInfoRow(
                    'Thời gian gửi', timeToString(report.ngayThangNam)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Helper method to create consistent info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

// Helper method to display images
  Widget _buildImageRow(String imageUrl1, String imageUrl2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (imageUrl1.isNotEmpty) _buildImageWidget(imageUrl1),
          if (imageUrl2.isNotEmpty) _buildImageWidget(imageUrl2),
        ],
      ),
    );
  }

// Helper method to create image with error handling
  Widget _buildImageWidget(String imageUrl) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50,
              ),
            );
          },
        ),
      ),
    );
  }

  String timeToString(String ngayThangNam) {
    // Check if the input string matches the expected format
    if (ngayThangNam.length != 15) {
      return ngayThangNam; // Return original string if format is unexpected
    }

    // Extract year, month, day, hour, and minute
    String year = ngayThangNam.substring(0, 4);
    String month = ngayThangNam.substring(4, 6);
    String day = ngayThangNam.substring(6, 8);
    String hour = ngayThangNam.substring(9, 11);
    String minute = ngayThangNam.substring(11, 13);

    // Format the date and time
    return '$day/$month/$year - $hour:$minute';
  }
}
