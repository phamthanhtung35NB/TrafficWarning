import 'dart:io';

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

  @override
  Widget build(BuildContext context) {

    var user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text('Báo cáo sự cố', style: TextStyle(color: Colors.black)),
        ),
      ),
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
                            size: 40, color: Colors.grey)
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
                            size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (_firstImagePath.isEmpty || _secondImagePath.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vui lòng chọn đầy đủ hình ảnh.')),
                    );
                    return;
                  }

                  if (_mapController.userLocationMarker == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Không tìm thấy vị trí người dùng.')),
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

                  String ngayThangNam = DateTime.now().toIso8601String();

                  String linkHinhAnh1 = await _firebasedb.uploadImage(
                      _firstImagePath, uid, 'image1.jpg');
                  String linkHinhAnh2 = await _firebasedb.uploadImage(
                      _secondImagePath, uid, 'image2.jpg');

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
                    _mapController.userLocationMarker!.point.latitude.toString(),
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
              },
              child: const Text('Gửi báo cáo'),
            ),

          ],
        ),
      ),
    );
  }
}
