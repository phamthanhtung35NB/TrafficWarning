import 'dart:io';

                  import 'package:latlong2/latlong.dart';
                  import 'package:geolocator/geolocator.dart';
                  import 'package:flutter/material.dart';
                  import 'package:mobile/screen/camera_screen.dart';
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
                    final TextEditingController _otherIncidentController = TextEditingController();
                    final TextEditingController _reportContentController = TextEditingController();
                    final CustomMapController _mapController = CustomMapController();
                    bool _isSubmitting = false;

                    @override
                    void dispose() {
                      _otherIncidentController.dispose();
                      _reportContentController.dispose();
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

                    Future<void> _submitReport(var user) async {
                      if (_firstImagePath.isEmpty || _secondImagePath.isEmpty) {
                        _showErrorSnackBar('Vui lòng chọn đầy đủ hình ảnh');
                        return;
                      }

                      String uid = user.uid ?? "";
                      if (uid.isEmpty) {
                        _showErrorSnackBar('Người dùng không xác định');
                        return;
                      }

                      setState(() {
                        _isSubmitting = true;
                      });

                      try {
                        String ngayThangNam0 = DateTime.now().toIso8601String();
                        DateTime dateTime = DateTime.parse(ngayThangNam0);
                        String ngayThangNam = "${dateTime.year}"
                            "${dateTime.month.toString().padLeft(2, '0')}"
                            "${dateTime.day.toString().padLeft(2, '0')}"
                            "_"
                            "${dateTime.hour.toString().padLeft(2, '0')}"
                            "${dateTime.minute.toString().padLeft(2, '0')}"
                            "${dateTime.second.toString().padLeft(2, '0')}";

                        String linkHinhAnh1 = await _firebasedb.uploadImage(
                            _firstImagePath, ngayThangNam, uid, generateFileName(1));
                        String linkHinhAnh2 = await _firebasedb.uploadImage(
                            _secondImagePath, ngayThangNam, uid, generateFileName(2));

                        Position position = await Geolocator.getCurrentPosition();
                        LatLng currentPosition = LatLng(position.latitude, position.longitude);
                        String userLocation =
                            "${currentPosition.latitude.toStringAsFixed(6)}, ${currentPosition.longitude.toStringAsFixed(6)}";

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

                        _showSuccessSnackBar('Gửi báo cáo thành công!');
                        _resetForm();
                      } catch (e) {
                        print('Error: $e');
                        _showErrorSnackBar('Gửi báo cáo thất bại: $e');
                      } finally {
                        setState(() {
                          _isSubmitting = false;
                        });
                      }
                    }

                    void _showSuccessSnackBar(String message) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }

                    void _showErrorSnackBar(String message) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }

                    void _resetForm() {
                      setState(() {
                        _selectedIncident = 'Ngập lụt';
                        _showOtherField = false;
                        _otherIncidentController.clear();
                        _reportContentController.clear();
                        // Reset image paths if needed
                      });
                    }

                    @override
                    Widget build(BuildContext context) {
                      var user = Provider.of<UserProvider>(context);
                      return Scaffold(
                        body: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Báo Cáo Sự Cố',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Divider(height: 30, thickness: 1),
                                const Text(
                                  'Chọn loại sự cố:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      border: InputBorder.none,
                                    ),
                                    isExpanded: true,
                                    value: _selectedIncident,
                                    items: <String>["Cháy", "Ngập lụt", "Tai nạn giao thông", "Khác"]
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
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
                                ),
                                const SizedBox(height: 20),
                                if (_showOtherField)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nhập loại sự cố khác:',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _otherIncidentController,
                                        decoration: InputDecoration(
                                          hintText: 'Loại sự cố khác',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Nội dung báo cáo:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _reportContentController,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText: 'Mô tả chi tiết về sự cố...',
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                const Text(
                                  'Hình ảnh sự cố:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildImageSelector(true),
                                    _buildImageSelector(false),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : () => _submitReport(user),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: _isSubmitting
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                          'GỬI BÁO CÁO',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    Widget _buildImageSelector(bool isFirst) {
                      String imagePath = isFirst ? _firstImagePath : _secondImagePath;
                      bool hasImage = imagePath != "/path/to/first/image.jpg" &&
                                      imagePath != "/path/to/second/image.jpg";

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => _captureImage(isFirst),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                image: hasImage
                                  ? DecorationImage(
                                      image: FileImage(File(imagePath)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              ),
                              child: !hasImage
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt, size: 40, color: Colors.grey.shade700),
                                        const SizedBox(height: 10),
                                        Text(
                                          isFirst ? 'Ảnh 1' : 'Ảnh 2',
                                          style: TextStyle(color: Colors.grey.shade700),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isFirst ? 'Hình ảnh 1' : 'Hình ảnh 2',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      );
                    }
                  }