import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/model/markerss.dart';
import 'package:mobile/widgets/animation_custom.dart';

class IconMarkersCustomDrawer extends StatelessWidget {
  final LatLng currentPosition; // Vị trí hiện tại của người dùng
  final Markerss marker; // Thông tin của marker

  const IconMarkersCustomDrawer({
    super.key,
    required this.currentPosition,
    required this.marker,
  });
  // Widget _buildMarkerIcon() {
  //   List<String> latLng = marker.latitudeLongitude.split(', ');
  //   LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
  //   double distance = _calculateDistance(currentPosition, markerPosition);
  //
  //   // Define the icon size
  //   double iconSize = 40.0;
  //
    // Build the bottom half with the location_on icon
//     Widget bottomIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
//
//     if (marker.level == 1) {
//       bottomIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
//     } else if (marker.level == 2) {
//       bottomIcon = Icon(Icons.location_on, color: Colors.orange, size: iconSize);
//     } else {
//       if (distance <= 1000) {
//         bottomIcon = Icon(Icons.location_on, color: Colors.black, size: iconSize);
//       } else {
//         bottomIcon = Icon(Icons.location_on, color: Colors.red, size: iconSize);
//       }
//     }
//
//     // Build the top half based on whether there is rain (marker.mua)
//     Widget topIcon = const SizedBox.shrink(); // Empty widget if no rain
//
//     // if (marker.mua) {
// // //   stackChildren.add(const Positioned(
// // //     top: -20, // Adjust this value to move the cloud icon higher without cutting it off
// // //     child: Padding(
// // //       padding: EdgeInsets.only(bottom: 5.0),
// // //       child: Icon(Icons.cloud, color: Colors.grey, size: 30.0),
// // //     ),
// // //   ));
// // // }
// //     if (marker.level > 2) {
// //       t.add(AnimationCustom());
// //     }
//     if (marker.mua) {
//       topIcon = const Padding(
//         padding: EdgeInsets.only(bottom: 1.0),
//         child: Icon(
//           Icons.cloud,
//           color: Colors.grey,
//           size: 30.0,
//         ),
//       ); // Show cloud icon if it rains
//     }
//
//     return Column(
//       mainAxisSize: MainAxisSize.min, // Ensure the column doesn't expand unnecessarily
//       children: [
//         // Top half
//         SizedBox(
//           height: (iconSize / 2)-15, // Half the height of the icon
//           child: Center(child: topIcon), // Center the cloud icon if it exists, or empty
//         ),
//
//         // Bottom half
//         SizedBox(
//           height: iconSize+5, // Full height of the location_on icon
//           child: bottomIcon, // Show the location_on icon
//         ),
//       ],
//     );
//   }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMarkerInfo(context), // Hiển thị thông tin marker khi nhấn vào
      child: _buildMarkerIcon(), // Xây dựng icon của marker
    );
  }

  Widget _buildMarkerIcon() {
    List<String> latLng = marker.latitudeLongitude.split(', ');
    LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
    double distance = _calculateDistance(currentPosition, markerPosition);

    // Define the icon size
    double iconSize = 40.0;

    // Build the location_on icon (it will be on top of the cloud)
    Widget locationIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);

    if (marker.level == 1) {
      locationIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
    } else if (marker.level == 2) {
      locationIcon = Icon(Icons.location_on, color: Colors.orange, size: iconSize);
    } else {
      if (distance <= 1000) {
        locationIcon = Icon(Icons.location_on, color: Colors.black, size: iconSize);
      } else {
        locationIcon = Icon(Icons.location_on, color: Colors.red, size: iconSize);
      }
    }

    // Build the cloud icon (it will be below the location icon)
    Widget cloudIcon = const SizedBox.shrink(); // Empty widget if no rain

    if (marker.mua) {
      cloudIcon = const Icon(
        Icons.cloud,
        color: Colors.grey,
        size: 30.0,
      ); // Show cloud icon if it rains
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Ensure the column doesn't expand unnecessarily
      children: [
        // Bottom half (cloud icon)
        SizedBox(
          height: (iconSize / 2), // Half the height of the icon
          child: Center(child: cloudIcon), // Center the cloud icon if it exists, or empty
        ),

        // Top half (location_on icon)
        SizedBox(
          height: iconSize, // Full height of the location_on icon
          child: locationIcon, // Show the location_on icon
        ),
      ],
    );
  }



//   Widget _buildMarkerIcon() {
//     List<String> latLng = marker.latitudeLongitude.split(', ');
//     LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
//     double distance = _calculateDistance(currentPosition, markerPosition);
//
//     Widget icon = Icon(Icons.location_on, color: Colors.blue, size: 40.0);
//
//     if (marker.level == 1) {
//       icon = Icon(Icons.location_on, color: Colors.blue, size: 40.0);
//     } else if (marker.level == 2) {
//       icon = Icon(Icons.location_on, color: Colors.orange, size: 40.0);
//     } else {
//       if (distance <= 1000) {
//         icon = Icon(Icons.location_on, color: Colors.black, size: 40.0);
//       } else {
//         icon = Icon(Icons.location_on, color: Colors.red, size: 40.0);
//       }
//     }
//
//     List<Widget> stackChildren = [icon];
//
//     if (marker.level > 2) {
//       stackChildren.add(AnimationCustom());
//     }
//
// //     if (marker.mua) {
// //   stackChildren.add(const Positioned(
// //     top: -20, // Adjust this value to move the cloud icon higher without cutting it off
// //     child: Padding(
// //       padding: EdgeInsets.only(bottom: 5.0),
// //       child: Icon(Icons.cloud, color: Colors.grey, size: 30.0),
// //     ),
// //   ));
// // }
//     if (marker.mua) {
//       stackChildren.add(
//         Positioned(
//           top: -20, // Keep the negative top value to move the cloud icon higher
//           child: OverflowBox(
//             maxHeight: 90.0, // Adjust this value to give enough space for the icon to overflow
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 5.0),
//               child: Icon(Icons.cloud, color: Colors.grey, size: 30.0),
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Stack(
//       alignment: Alignment.center,
//       children: stackChildren,
//     );
//   }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371000; // Bán kính Trái đất theo mét
    double lat1 = pos1.latitude * pi / 180; // Chuyển vĩ độ từ độ sang radian
    double lon1 = pos1.longitude * pi / 180; // Chuyển kinh độ từ độ sang radian
    double lat2 = pos2.latitude * pi / 180;
    double lon2 = pos2.longitude * pi / 180;

    double dLat = lat2 - lat1; // Chênh lệch vĩ độ
    double dLon = lon2 - lon1; // Chênh lệch kinh độ

    // Công thức Haversine để tính khoảng cách giữa hai điểm trên bề mặt Trái đất
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c; // Khoảng cách theo mét
    return distance;
  }

  void _showMarkerInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông tin thiết bị'), // Tiêu đề của hộp thoại
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level: ${marker.level}'), // Hiển thị level của marker
              Text('Other: ${marker.other}'), // Hiển thị thông tin khác của marker
              Text('Mua: ${marker.mua}'), // Hiển thị thông tin mưa
              Text('Ngap: ${marker.ngap}'), // Hiển thị thông tin ngập
              Text('Water Depth: ${marker.waterDepth} cm'), // Hiển thị độ sâu nước
              Text('UV: ${marker.uv}'), // Hiển thị chỉ số UV
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Đóng hộp thoại khi nhấn nút
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}