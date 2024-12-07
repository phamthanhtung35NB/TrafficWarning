import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/services/firebasedb.dart';
import 'package:mobile/model/markerss.dart';
import 'package:mobile/widgets/icon_markers.dart';
import 'package:mobile/widgets/pulsing_marker.dart';
import 'package:mobile/widgets/image_report_marker.dart';
import 'package:mobile/widgets/uv_marker.dart';

import '../model/markers_reports.dart';
import '../model/markers_uv.dart';

class CustomMapController {
  List<Marker> markers = [];
  Marker? userLocationMarker;
  LatLng currentPosition = LatLng(21.038859, 105.785613);

  final Firebasedb firebasedb = Firebasedb();
  final MapController mapController = MapController();

  // Get current location
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Dịch vụ định vị đã bị vô hiệu hóa.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Quyền vị trí bị từ chối');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Quyền truy cập vị trí bị từ chối vĩnh viễn, chúng tôi không thể yêu cầu cấp quyền.');
    }

    Position position = await Geolocator.getCurrentPosition();
    currentPosition = LatLng(position.latitude, position.longitude);

    // Cập nhật marker với PulsingMarker
    userLocationMarker = Marker(
      width: 60.0, // Tăng kích thước để chứa animation
      height: 60.0,
      point: currentPosition,
      builder: (ctx) => PulsingMarker(),
    );

    // Nếu bạn muốn theo dõi heading (hướng di chuyển)
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      currentPosition = LatLng(position.latitude, position.longitude);
      userLocationMarker = Marker(
        width: 60.0,
        height: 60.0,
        point: currentPosition,
        builder: (ctx) => PulsingMarker(),
      );
    });
  }
  void updateLocation(Position position) {
    currentPosition = LatLng(position.latitude, position.longitude);
    userLocationMarker = Marker(
      width: 60.0,
      height: 60.0,
      point: currentPosition,
      builder: (ctx) => PulsingMarker(),
    );
  }
  // Lắng nghe thay đổi của imageReports và uv
  void listenToDeviceChanges() {
    firebasedb.listenToDeviceChanges((devices) {
      _updateMarkers(devices, 'device');
    });
    firebasedb.listenToImageReportsChanges((imageReports) {
      _updateMarkers(imageReports, 'imageReport');
    });
    firebasedb.listenToUVChanges((uvReports) {
      _updateMarkers(uvReports, 'uv');
    });
  }
void _updateMarkers(Map<String, dynamic> data, String type) {
  List<Marker> newMarkers = [];
  data.forEach((key, value) {
    if (type == 'device') {
      Markerss marker = Markerss.fromJson(Map<String, dynamic>.from(value));
      List<String> latLng = marker.latitudeLongitude.split(', ');
      newMarkers.add(
        Marker(
          width: 50.0,
          height: 50.0,
          point: LatLng(double.parse(latLng[0]), double.parse(latLng[1])),
          builder: (ctx) => IconMarkersCustomDrawer(
            currentPosition: currentPosition,
            marker: marker,
          ),
        ),
      );
    } else if (type == 'imageReport') {
      MarkersReports report = MarkersReports.fromJson(Map<String, dynamic>.from(value));
      List<String> latLng = report.latitudeLongitude.split(', ');
      newMarkers.add(
        Marker(
          width: 50.0,
          height: 50.0,
          point: LatLng(double.parse(latLng[0]), double.parse(latLng[1])),
          builder: (ctx) => ImageReportMarker(report: report),
        ),
      );
    } else if (type == 'uv') {
      MarkersUV uvReport = MarkersUV.fromJson(Map<String, dynamic>.from(value));
      List<String> latLng = uvReport.latitudeLongitude.split(', ');
      newMarkers.add(
        Marker(
          width: 50.0,
          height: 50.0,
          point: LatLng(double.parse(latLng[0]), double.parse(latLng[1])),
          builder: (ctx) => UVMarker(uvReport: uvReport),
        ),
      );
    }
  });
  markers.addAll(newMarkers);
}
  // void _updateMarkers(Map<String, dynamic> data, String type) {
  //   List<Marker> newMarkers = [];
  //   data.forEach((key, value) {
  //     if (type == 'device') {
  //       Markerss marker = Markerss.fromJson(Map<String, dynamic>.from(value));
  //       List<String> latLng = marker.latitudeLongitude.split(', ');
  //       newMarkers.add(
  //         Marker(
  //           width: 50.0,
  //           height: 50.0,
  //           point: LatLng(double.parse(latLng[0]), double.parse(latLng[1])),
  //           builder: (ctx) => IconMarkersCustomDrawer(
  //             currentPosition: currentPosition,
  //             marker: marker,
  //           ),
  //         ),
  //       );
  //     } else if (type == 'imageReport') {
  //       List<String> latLng = value['latitudeLongitude'].split(', ');
  //       newMarkers.add(
  //         Marker(
  //           width: 50.0,
  //           height: 50.0,
  //           point: LatLng(double.parse(latLng[0]), double.parse(latLng[1])),
  //           builder: (ctx) => ImageReportMarker(),
  //         ),
  //       );
  //     } else if (type == 'uv') {
  //       List<String> latLng = value['latitudeLongitude'].split(', ');
  //       newMarkers.add(
  //         Marker(
  //           width: 50.0,
  //           height: 50.0,
  //           point: LatLng(double.parse(latLng[0]), double.parse(latLng[1])),
  //           builder: (ctx) => UVMarker(),
  //         ),
  //       );
  //     }
  //   });
  //   markers.addAll(newMarkers);
  // }

  // hiển thị thông tin thiết bị
  // void _showDeviceInfo(BuildContext context, int level, String other, bool mua, bool ngap, int waterDepth, double uv) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Thông tin thiết bị'),
  //         // nền xám
  //         backgroundColor: Colors.grey[500],
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             if (level == 1)
  //               Text ('Cảnh báo mực nước cấp: $level' , style: const TextStyle(color: Colors.yellow))
  //             else if (level == 2)
  //               Text('Cảnh báo mục nước cấp: $level', style: const TextStyle(color: Colors.orange))
  //             else if (level == 3)
  //                 Text('Cảnh báo mục nước cấp: $level', style: const TextStyle(color: Colors.red)),
  //
  //             if (mua==true)
  //               const Text('Có mưa')
  //             else
  //               const Text('Không mưa'),
  //             if (ngap==true)
  //               const Text('Có ngập')
  //             else
  //               const Text('Không ngập'),
  //             if (waterDepth > 0)
  //               Text('Độ sâu nước: $waterDepth cm')
  //             else if (waterDepth>10)
  //               Text('Độ sâu nước: $waterDepth cm', style: const TextStyle(color: Colors.red))
  //             else
  //               const Text('Độ sâu nước: Không xác định'),
  //             if (uv > 0)
  //               Text('Tia cực tím: $uv')
  //             else if (uv>10)
  //               Text('Tia cực tím: $uv', style: const TextStyle(color: Colors.red))
  //             else
  //               const Text('Tia cực tím: Không xác định'),
  //             Text('Khác: $other'),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Đóng'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}