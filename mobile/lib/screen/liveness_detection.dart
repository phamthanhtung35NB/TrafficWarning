import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:async';
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
  bool _leftEyeClosed = false;
  bool _rightEyeClosed = false;
  Timer? _timer;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
      enableClassification: true, // Bật tính năng phân loại mắt mở/đóng
    ));
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![1], // Camera trước
        ResolutionPreset.medium,
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
    // Chuyển đổi ảnh Camera thành định dạng cần thiết cho ML Kit
    // final InputImageRotation rotation =
    //     InputImageRotationMethods.fromRawValue(_cameraController!.description.sensorOrientation) ??
    //         InputImageRotation.rotation0deg;
    final InputImageRotation rotation = InputImageRotationMethods.fromRawValue(
            _cameraController!.description.sensorOrientation) ??
        InputImageRotation.Rotation_0deg;

    final InputImage inputImage = _convertCameraImage(image, rotation);
    final List<Face> faces = await _faceDetector!.processImage(inputImage);

    if (faces.isNotEmpty) {
      final face = faces[0];
      _checkLiveness(face);
    }

    _isDetecting = false;
  }

  InputImage _convertCameraImage(
      CameraImage image, InputImageRotation rotation) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    return InputImage.fromBytes(
      bytes: bytes,
      inputImageData: InputImageData(
        size: imageSize,
        imageRotation: rotation,
        inputImageFormat:
            InputImageFormatMethods.fromRawValue(image.format.raw) ??
                InputImageFormat.NV21,
        planeData: planeData,
      ),
    );
  }

  void _checkLiveness(Face face) {
    final leftEyeOpenProbability = face.leftEyeOpenProbability;
    final rightEyeOpenProbability = face.rightEyeOpenProbability;

    // In ra giá trị của xác suất mắt mở
    print('Left Eye Open Probability: $leftEyeOpenProbability');
    print('Right Eye Open Probability: $rightEyeOpenProbability');

    if (leftEyeOpenProbability != null && rightEyeOpenProbability != null) {
      if (leftEyeOpenProbability < 0.5 && rightEyeOpenProbability < 0.5) {
        _leftEyeClosed = true;
        _rightEyeClosed = true;
      }

      if (_leftEyeClosed &&
          _rightEyeClosed &&
          leftEyeOpenProbability > 0.8 &&
          rightEyeOpenProbability > 0.8) {
        setState(() {
          _isLivenessDetected = true;
        });
        _showLivenessResult();
      }
    }
  }

  void _showLivenessResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liveness Detected: Mắt đã được mở!'),
        duration: Duration(seconds: 2),
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
                CameraPreview(_cameraController!),
                if (_isLivenessDetected)
                  Center(
                    child: Text(
                      'Liveness Detected!',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    ),
                  ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
