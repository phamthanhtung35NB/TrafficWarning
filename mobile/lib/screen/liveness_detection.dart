import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:mobile/screen/preview_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  bool _isLivenessDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
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

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized || !_isLivenessDetected) {
      return;
    }
    try {
      final XFile image = await _cameraController!.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      print('Không thể chụp ảnh: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkLiveness() async {
    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(enableClassification: true),
    );

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final cameraImage = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(cameraImage.path);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        // Assume liveness if a face is detected
        setState(() {
          _isLivenessDetected = true;
        });
      } else {
        setState(() {
          _isLivenessDetected = false;
        });
      }
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
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _checkLiveness,
                    child: Text("Kiểm tra liveness"),
                  ),
                  ElevatedButton(
                    onPressed: _takePicture,
                    child: Icon(Icons.camera),
                  ),
                ],
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