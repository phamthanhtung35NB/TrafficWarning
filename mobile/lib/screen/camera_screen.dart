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
  double _zoomLevel = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  bool _isFlashOn = false;

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
      _minZoom = await _cameraController!.getMinZoomLevel();
      _maxZoom = await _cameraController!.getMaxZoomLevel();

      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      print('Không có camera khả dụng.');
    }
  }

  void _zoomIn() {
    print("Zoom Level: $_zoomLevel");

    if (_zoomLevel < _maxZoom) {
      setState(() {
        _zoomLevel += 1;
        _cameraController?.setZoomLevel(_zoomLevel.clamp(_minZoom, _maxZoom));
      });
    }
  }

  void _zoomOut() {
    print("Zoom Level: $_zoomLevel");

    if (_zoomLevel > _minZoom) {
      setState(() {
        _zoomLevel -= 1;
        _cameraController?.setZoomLevel(_zoomLevel.clamp(_minZoom, _maxZoom));
      });
    }
  }

  void _toggleFlash() async {
    _isFlashOn = !_isFlashOn;
    await _cameraController?.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final XFile image = await _cameraController!.takePicture();
      Navigator.pop(context, image.path); // Trả về đường dẫn ảnh
    } catch (e) {
      print('Không thể chụp ảnh: $e');
    }
  }


  void _handlePinchZoom(ScaleUpdateDetails details) {
    double newZoomLevel = _zoomLevel * details.scale;

    // Giới hạn zoom trong khoảng cho phép
    newZoomLevel = newZoomLevel.clamp(_minZoom, _maxZoom);

    setState(() {
      _zoomLevel = newZoomLevel;
      _cameraController?.setZoomLevel(_zoomLevel);
    });
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
        title: const Align(
          alignment: Alignment.center,
          child: Text('Chụp ảnh hiện trường',
              style: TextStyle(color: Colors.black)),
        ),
      ),
      body: _isCameraInitialized
          ? GestureDetector(
              onScaleUpdate: (ScaleUpdateDetails details) {
                _handlePinchZoom(details);
              },
              child: Stack(
                children: [
                  CameraPreview(_cameraController!),
                  Positioned(
                    bottom: 70,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // Căn đều 2 bên
                      children: [
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.black, // background color
                              borderRadius:
                                  BorderRadius.circular(10), // optional
                            ),
                            child: const Icon(Icons.remove,
                                color: Colors.white, size: 40),
                          ),
                          onPressed: _zoomOut,
                        ),
                        Text(
                          '${_zoomLevel.toStringAsFixed(1)}x',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 19),
                        ),
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.black, // background color
                              borderRadius:
                                  BorderRadius.circular(10), // optional
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 40),
                          ),
                          onPressed: _zoomIn,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      // Căn đều 2 bên
                      children: [
                        ElevatedButton(
                          //size: 50,

                          onPressed: _takePicture,
                          child: const Icon(Icons.camera,
                              color: Colors.black, size: 40),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      //size: 50,
                      iconSize: 40,
                      icon: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:mobile/screen/preview_screen.dart';
//
// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }
//
// class _CameraScreenState extends State<CameraScreen> {
//   CameraController? _cameraController;
//   List<CameraDescription>? cameras;
//   bool _isCameraInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }
//
//   // Hàm khởi tạo camera
//   Future<void> _initializeCamera() async {
//     cameras = await availableCameras(); // Lấy danh sách camera trên thiết bị
//
//     if (cameras != null && cameras!.isNotEmpty) {
//       _cameraController = CameraController(
//         cameras![0],
//         // Sử dụng camera trước hoặc sau (0 là camera sau, 1 là camera trước)
//         ResolutionPreset.high,
//       );
//
//       await _cameraController?.initialize();
//       setState(() {
//         _isCameraInitialized = true;
//       });
//     } else {
//       print('Không có camera khả dụng.');
//     }
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }
//
//   // Hàm chụp ảnh
//   Future<void> _takePicture() async {
//     if (!_cameraController!.value.isInitialized) {
//       return;
//     }
//     try {
//       final XFile image = await _cameraController!.takePicture();
//
//       print("Xem trước ảnh: ${image.path}");
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PreviewScreen(imagePath: image.path),
//         ),
//       );
//       print('Ảnh đã được chụp: ${image.path}');
//     } catch (e) {
//       print('Không thể chụp ảnh: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tích hợp camera vào ứng dụng'),
//       ),
//       body: _isCameraInitialized
//           ? Stack(
//               children: [
//                 CameraPreview(_cameraController!), // Xem trước camera
//                 Positioned(
//                   bottom: 20,
//                   left: 0,
//                   right: 0,
//                   child: Center(
//                     child: ElevatedButton(
//                       onPressed: _takePicture,
//                       child: Icon(Icons.camera),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           : Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }
// }
