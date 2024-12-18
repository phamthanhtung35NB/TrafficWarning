import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screen/dual_camera_screen.dart';
import 'package:mobile/screen/camera_screen.dart';
import 'package:mobile/screen/liveness_detection.dart';
import 'package:mobile/services/firebasedb.dart';
import 'package:provider/provider.dart';
import 'package:mobile/controller/map_controller.dart';
import '../model/UserProvider.dart';
import '../model/user_reports.dart';

class ErrorWarning extends StatefulWidget {
  const ErrorWarning({super.key});

  @override
  _ErrorWarningState createState() => _ErrorWarningState();
}

class _ErrorWarningState extends State<ErrorWarning> {
  final Firebasedb _firebasedb = Firebasedb();
  String _firstImagePath = "/path/to/first/image.jpg";
  String _secondImagePath = "/path/to/second/image.jpg";
  String _selectedIncident = 'Ngập lụt';
  bool _showOtherField = false;
  TextEditingController _otherIncidentController = TextEditingController();
  final CustomMapController _mapController = CustomMapController();

  // String? _firstImagePath; // Lưu đường dẫn ảnh đầu tiên
  // String? _secondImagePath; // Lưu đường dẫn ảnh thứ hai

  @override
  void dispose() {
    _otherIncidentController.dispose();
    super.dispose();
  }

  Future<void> _captureImage(bool isFirstImage) async {
    final imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );

    if (imagePath != null) {
      setState(() {
        if (isFirstImage) {
          _firstImagePath = imagePath;
        } else {
          _secondImagePath = imagePath;
        }
      });
    }
  }

  // Hàm lấy tên file theo định dạng yêu cầu
  String generateFileName(int index) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}"
        "${now.month.toString().padLeft(2, '0')}"
        "${now.day.toString().padLeft(2, '0')}"
        "_"
        "${now.hour.toString().padLeft(2, '0')}"
        "${now.minute.toString().padLeft(2, '0')}"
        "${now.second.toString().padLeft(2, '0')}";
    return "${formattedDate}_$index.jpg";
  }

  //summit report
  Future<void> _submitReport(var user) async {
    try {
      if (_firstImagePath.isEmpty || _secondImagePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn đầy đủ hình ảnh.')),
        );
        return;
      }
      String uid = user.uid ?? "";
      if (uid.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Người dùng không xác định.')),
        );
        return;
      }

      String ngayThangNam0 = DateTime.now().toIso8601String();

      // Chuyển đổi thành định dạng không có ký tự đặc biệt
      print('ngayThangNam gốc: $ngayThangNam0');

      // Chuyển đổi thành định dạng không có ký tự đặc biệt
      DateTime dateTime = DateTime.parse(ngayThangNam0);
      String ngayThangNam = "${dateTime.year}"
          "${dateTime.month.toString().padLeft(2, '0')}"
          "${dateTime.day.toString().padLeft(2, '0')}"
          "_"
          "${dateTime.hour.toString().padLeft(2, '0')}"
          "${dateTime.minute.toString().padLeft(2, '0')}"
          "${dateTime.second.toString().padLeft(2, '0')}";
      print('ngayThangNam mới: $ngayThangNam');

      print('uid: $uid');
      print('_firstImagePath: $_firstImagePath');
      print('_secondImagePath: $_secondImagePath');
      String linkHinhAnh1 = await _firebasedb.uploadImage(
          _firstImagePath, ngayThangNam, uid, generateFileName(1));
      String linkHinhAnh2 = await _firebasedb.uploadImage(
          _secondImagePath, ngayThangNam, uid, generateFileName(2));
      Position position = await Geolocator.getCurrentPosition();
      LatLng currentPosition = LatLng(position.latitude, position.longitude);

      // Chuyển đổi vị trí người dùng thành chuỗi định dạng yêu cầu
      String userLocation =
          "${currentPosition.latitude.toStringAsFixed(6)}, ${currentPosition.longitude.toStringAsFixed(6)}";
      print('userLocation: $userLocation');
      UserReports report = UserReports(
        uid,
        user.email ?? "",
        user.hoVaTen ?? "",
        user.linkFaceId ?? "",
        user.namsinh ?? 0,
        user.sdt ?? "",
        _selectedIncident == 'Khác'
            ? _otherIncidentController.text
            : _selectedIncident,
        userLocation,
        "12:00",
        "12:00",
        ngayThangNam,
        linkHinhAnh1,
        linkHinhAnh2,
        true,
      );

      await _firebasedb.saveUserReport(report);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi báo cáo thành công!')),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi báo cáo thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn loại sự cố:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedIncident,
              items: <String>["Cháy", "Ngập lụt", "Tai nạn giao thông", "Khác"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.center,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedIncident = newValue!;
                  _showOtherField = _selectedIncident == 'Khác';
                });
              },
            ),
            SizedBox(height: 20),
            if (_showOtherField)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nhập loại sự cố khác:', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  TextField(
                    controller: _otherIncidentController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Loại sự cố khác',
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nội dung báo cáo',
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Ô vuông đầu tiên
                GestureDetector(
                  onTap: () => _captureImage(true), // Chụp ảnh đầu tiên
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: _firstImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_firstImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _firstImagePath == null
                        ? const Icon(Icons.camera_alt,
                            size: 40, color: Colors.black)
                        : null,
                  ),
                ),
                // Ô vuông thứ hai
                GestureDetector(
                  onTap: () => _captureImage(false), // Chụp ảnh thứ hai
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: _secondImagePath != null
                          ? DecorationImage(
                              image: FileImage(File(_secondImagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _secondImagePath == null
                        ? const Icon(Icons.camera_alt,
                            size: 40, color: Colors.black)
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitReport(user),
              child: const Text('Gửi báo cáo'),
            ),
          ],
        ),
      ),
    );
  }
}
