import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Hàm khởi tạo camera
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();  // Lấy danh sách camera trên thiết bị

    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],  // Sử dụng camera trước hoặc sau (0 là camera sau, 1 là camera trước)
        ResolutionPreset.high,
      );

      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      print('Không có camera khả dụng.');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Hàm chụp ảnh
  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final XFile image = await _cameraController!.takePicture();
      print('Ảnh đã được chụp: ${image.path}');
    } catch (e) {
      print('Không thể chụp ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tích hợp camera vào ứng dụng'),
      ),
      body: _isCameraInitialized
          ? Stack(
        children: [
          CameraPreview(_cameraController!),  // Xem trước camera
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _takePicture,
                child: Icon(Icons.camera),
              ),
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
