import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class LivenessDetectionScreen extends StatefulWidget {
  @override
  _LivenessDetectionScreenState createState() =>
      _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _isLivenessDetected = false;
  int _faceCount = 0; // Biến để lưu số lượng khuôn mặt phát hiện được
  double _leftEyeOpenProbability = 0.0;
  double _rightEyeOpenProbability = 0.0;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableClassification: true, // Phân loại mắt mở/đóng
        enableTracking: true,       // Theo dõi khuôn mặt
      ),
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![1], // Camera trước
        ResolutionPreset.high, // Chế độ phân giải cao
      );
      await _cameraController?.initialize();
      setState(() {});

      // Bắt đầu phát hiện khuôn mặt
      _cameraController?.startImageStream((CameraImage image) {
        if (!_isDetecting) {
          _isDetecting = true;
          _detectFaces(image);
        }
      });
    }
  }

  Future<void> _detectFaces(CameraImage image) async {
    try {
      final rotation = _cameraController?.description.sensorOrientation != null
          ? InputImageRotationMethods.fromRawValue(
          _cameraController!.description.sensorOrientation) ??
          InputImageRotation.Rotation_0deg
          : InputImageRotation.Rotation_0deg;

      final InputImage inputImage = _convertCameraImage(image, rotation);
      final List<Face> faces = await _faceDetector!.processImage(inputImage);

      setState(() {
        _faceCount = faces.length; // Cập nhật số khuôn mặt phát hiện được
      });

      if (faces.isNotEmpty) {
        final face = faces[0];
        _checkLiveness(face);
      }
    } catch (e) {
      print('Lỗi khi phát hiện khuôn mặt: $e');
    } finally {
      _isDetecting = false;
    }
  }

  InputImage _convertCameraImage(
      CameraImage image, InputImageRotation rotation) {
    final planes = image.planes;
    final bytes = planes[0].bytes; // Lấy bytes từ plane đầu tiên
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final planeData = planes.map((Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    }).toList();

    return InputImage.fromBytes(
      bytes: bytes,
      inputImageData: InputImageData(
        size: imageSize,
        imageRotation: rotation,
        inputImageFormat: InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21,
        planeData: planeData,
      ),
    );
  }

  void _checkLiveness(Face face) {
    final leftEyeOpenProbability = face.leftEyeOpenProbability;
    final rightEyeOpenProbability = face.rightEyeOpenProbability;

    setState(() {
      _leftEyeOpenProbability = leftEyeOpenProbability ?? 0.0;
      _rightEyeOpenProbability = rightEyeOpenProbability ?? 0.0;
    });

    if (leftEyeOpenProbability != null &&
        rightEyeOpenProbability != null &&
        leftEyeOpenProbability > 0.5 &&
        rightEyeOpenProbability > 0.5) {
      setState(() {
        _isLivenessDetected = true;
      });
      // _showLivenessResult();
    }
  }

  void _showLivenessResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liveness Detected!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liveness Detection'),
      ),
      body: _cameraController != null && _cameraController!.value.isInitialized
          ? Stack(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi), // Lật ảnh camera trước
            child: CameraPreview(_cameraController!),
          ),
          if (_isLivenessDetected)
            Positioned(
              top: 90,
              left: 20,
              child: Text(
                'Đã nhận diện người thật: $_isLivenessDetected',
                style: TextStyle(fontSize: 24, color: Colors.green),
              ),
            ),
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              'Số khuôn mặt phát hiện được: $_faceCount',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          Positioned(
            top: 70,
            left: 20,
            child: Text(
              'Mắt trái mở: ${_leftEyeOpenProbability.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Mắt phải mở: ${_rightEyeOpenProbability.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
