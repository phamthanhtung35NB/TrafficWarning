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
          title: const Text('Thông tin báo cáo hình ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ngày tháng năm: ${report.ngayThangNam}'),
              Text('Email: ${report.email}'),
              Text('Hiệu lực: ${report.hieuLuc}'),
              Text('Hình ảnh 1: ${report.hinhAnh1}'),
              Text('Hình ảnh 2: ${report.hinhAnh2}'),
              Text('Họ và tên: ${report.hoVaTen}'),
              Text('Vị trí: ${report.latitudeLongitude}'),
              Text('Link Face ID: ${report.linkFaceId}'),
              Text('Loại sự cố: ${report.loaiSuCo}'),
              Text('Năm sinh: ${report.namsinh}'),
              Text('Nội dung: ${report.noiDung}'),
              Text('Số điện thoại: ${report.sdt}'),
              Text('Thời gian: ${report.thoiGian}'),
              Text('UID: ${report.uid}'),
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