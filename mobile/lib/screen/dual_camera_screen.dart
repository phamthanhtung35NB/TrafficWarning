import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class DualCameraScreen extends StatefulWidget {
  @override
  _DualCameraScreenState createState() => _DualCameraScreenState();
}

class _DualCameraScreenState extends State<DualCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int selectedCameraIndex = 0; // Chọn camera trước hoặc sau
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(selectedCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![cameraIndex],
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

  void _switchCamera() {
    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0; // Chuyển đổi camera
    _initializeCamera(selectedCameraIndex);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sử dụng camera trước và sau'),
      ),
      body: _isCameraInitialized
          ? Stack(
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _switchCamera,
                  child: Icon(Icons.switch_camera),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final image = await _cameraController?.takePicture();
                    if (image != null) {
                      print('Ảnh đã chụp: ${image.path}');
                    }
                  },
                  child: Icon(Icons.camera),
                ),
              ],
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
