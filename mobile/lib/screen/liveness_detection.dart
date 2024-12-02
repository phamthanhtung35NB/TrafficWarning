import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class LivenessDetectionScreen extends StatefulWidget {
  @override
  _LivenessDetectionScreenState createState() =>
      _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  FlutterTts _flutterTts = FlutterTts();
  bool _isDetecting = false;
  bool _isLivenessDetected = false;
  int _faceCount = 0;
  double _leftEyeOpenProbability = 0.0;
  double _rightEyeOpenProbability = 0.0;
  List<CameraDescription>? _cameras;
  int _currentActionIndex = 0; // Hành động hiện tại
  bool _hasSpokenSuccess = false; // Kiểm soát lời nói thành công.

  List<String> _actions = [
    'Hãy giữ nguyên mắt phải và nhắm mắt trái',
    'Hãy mở mắt trái và nhắm mắt phải',
    'Hãy nhắm cả hai mắt',
    'được rồi hãy mở cả hai mắt'
  ];
  Timer? _noFaceTimer; // Timer để kiểm soát thông báo không có khuôn mặt.
  Timer? _actionReminderTimer; // Timer để nhắc lại yêu cầu hành động.
  double _eyeClosedThreshold =
      0.3; // Ngưỡng xác định mắt nhắm (điều chỉnh từ 0.0 đến 1.0).
  @override
  void dispose() {
    _actionReminderTimer?.cancel();
    _noFaceTimer?.cancel();
    _cameraController?.dispose();
    _faceDetector?.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
      ),
    );
    _speak('Hãy đưa khuôn mặt của bạn vào camera');
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![1],
        ResolutionPreset.high,
      );
      await _cameraController?.initialize();
      setState(() {});

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

      if (faces.isEmpty) {
        setState(() {
          _faceCount = 0;
          _resetActions();
        });

        if (_noFaceTimer == null || !_noFaceTimer!.isActive) {
          _speak('Hãy đưa khuôn mặt của bạn vào camera');
          _noFaceTimer = Timer(Duration(seconds: 6), () {});
        }
      } else if (faces.length > 1) {
        setState(() {
          _resetActions();
        });
        _speak('Chỉ được phép có một khuôn mặt trong khung hình');
      } else {
        _noFaceTimer?.cancel(); // Hủy Timer khi phát hiện khuôn mặt.

        final face = faces[0];

        if (_faceCount == 0) {
          _speak(
              "Giữ khuôn mặt ở vị trí này và làm theo chỉ dẫn. \n \n \n               bắt đầu xác minh"); // Chỉ phát khi phát hiện lần đầu.
        }

        setState(() {
          _faceCount = 1;
          _checkLiveness(face);
        });
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
    final bytes = planes[0].bytes;
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
        inputImageFormat:
            InputImageFormatMethods.fromRawValue(image.format.raw) ??
                InputImageFormat.NV21,
        planeData: planeData,
      ),
    );
  }

  void _checkLiveness(Face face) {
    double leftEyeOpenProbability;
    double rightEyeOpenProbability;

    if (_cameraController?.description.lensDirection ==
        CameraLensDirection.front) {
      // Đảo ngược mắt trái và mắt phải nếu dùng camera trước
      leftEyeOpenProbability = face.rightEyeOpenProbability ?? 0.0;
      rightEyeOpenProbability = face.leftEyeOpenProbability ?? 0.0;
    } else {
      leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0.0;
      rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0.0;
    }

    setState(() {
      _leftEyeOpenProbability = leftEyeOpenProbability;
      _rightEyeOpenProbability = rightEyeOpenProbability;
    });

    final currentAction = _actions[_currentActionIndex];

    // Kiểm tra từng hành động và chuyển sang bước tiếp theo nếu đúng.
    if (_currentActionIndex == 0 &&
        leftEyeOpenProbability < _eyeClosedThreshold) {
      _nextAction();
    } else if (_currentActionIndex == 1 &&
        rightEyeOpenProbability < _eyeClosedThreshold) {
      _nextAction();
    } else if (_currentActionIndex == 2 &&
        leftEyeOpenProbability < _eyeClosedThreshold &&
        rightEyeOpenProbability < _eyeClosedThreshold) {
      _nextAction();
    } else if (_currentActionIndex == 3 &&
        leftEyeOpenProbability > _eyeClosedThreshold &&
        rightEyeOpenProbability > _eyeClosedThreshold) {
      _nextAction(success: true);
    } else {
      // Nếu hành động chưa được thực hiện, nhắc lại sau 5 giây.
      _startActionReminder(currentAction);
    }
  }

  void _nextAction({bool success = false}) async {
    _actionReminderTimer?.cancel(); // Hủy nhắc nhở khi chuyển bước.

    if (success) {
      if (!_hasSpokenSuccess) {
        setState(() {
          _isLivenessDetected = true;
          _hasSpokenSuccess = true; // Đánh dấu đã nói thành công.
        });
        print("-2222222222222");
        _speak('Xác minh thành công');

        // Chụp ảnh khi người dùng mở mắt
        await _captureAndUploadImage();
      }
    } else {
      setState(() {
        _currentActionIndex = (_currentActionIndex + 1) % _actions.length;
      });
      _speak(_actions[_currentActionIndex]);
    }
  }

  Future<void> _captureAndUploadImage() async {
    try {
      // Lấy đường dẫn thư mục Authentication
      final directory = await getApplicationDocumentsDirectory();
      final directoryPath = '${directory.path}/Authentication';

      // Tạo thư mục nếu chưa tồn tại
      final directoryExist = Directory(directoryPath).existsSync();
      if (!directoryExist) {
        Directory(directoryPath).createSync();
      }

      // Chụp ảnh từ camera
      final image = await _cameraController?.takePicture();
      if (image != null) {
        final imagePath =
            '${directoryPath}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Lưu ảnh vào bộ nhớ
        final File file = File(imagePath);
        await file.writeAsBytes(await image.readAsBytes());

        // Upload ảnh lên Firebase Storage
        await _uploadImageToStorage(file);
      }
    } catch (e) {
      print('Lỗi khi chụp và tải ảnh lên: $e');
    }
  }

  Future<void> _uploadImageToStorage(File file) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('authentication/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Ảnh đã được tải lên thành công. URL: $downloadUrl');

      // Quay lại màn hình trước và trả về link ảnh
      Navigator.pop(context, downloadUrl);
    } catch (e) {
      print('Lỗi khi tải ảnh lên Firebase Storage: $e');
    }
  }

  void _startActionReminder(String action) {
    if (_actionReminderTimer == null || !_actionReminderTimer!.isActive) {
      _actionReminderTimer = Timer.periodic(Duration(seconds: 5), (_) {
        if (!_isSpeaking) {
          _speak(action);
        }
      });
    }
  }

  void _resetActions() {
    _actionReminderTimer?.cancel(); // Hủy Timer khi khởi động lại quy trình.
    setState(() {
      _isLivenessDetected = false;
      _currentActionIndex = 0;
      _hasSpokenSuccess = false; // Đặt lại cờ khi bắt đầu lại.
    });
  }

  bool _isSpeaking = false; // Cờ kiểm tra trạng thái TTS.

  Future<void> _speak(String text) async {
    if (_isSpeaking) return; // Bỏ qua nếu đang phát âm thanh.

    _isSpeaking = true;
    await _flutterTts.speak(text).then((_) {
      _isSpeaking = false; // Đặt lại cờ sau khi hoàn thành.
    }).catchError((_) {
      _isSpeaking = false; // Đặt lại cờ nếu có lỗi.
    });
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
                  transform: Matrix4.rotationY(math.pi),
                  child: CameraPreview(_cameraController!),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Text(
                    'Hành động: ${_actions[_currentActionIndex]}',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: Text(
                    'Số khuôn mặt phát hiện được: $_faceCount',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: 20,
                  child: Text(
                    'Mắt trái mở: ${_leftEyeOpenProbability.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                Positioned(
                  top: 110,
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
