import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/model/markerss.dart';
import 'package:mobile/services/flutter_tts_custom.dart';

class IconMarkersCustomDrawer extends StatefulWidget {
  final LatLng currentPosition; // Vị trí hiện tại của người dùng
  final Markerss marker; // Thông tin của marker

  const IconMarkersCustomDrawer({
    super.key,
    required this.currentPosition,
    required this.marker,
  });

  @override
  _IconMarkersCustomDrawerState createState() =>
      _IconMarkersCustomDrawerState();
}

class _IconMarkersCustomDrawerState extends State<IconMarkersCustomDrawer> {
  bool isSpeaking = false; // Biến trạng thái cho việc phát âm thanh

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMarkerInfo(context),
      // Hiển thị thông tin marker khi nhấn vào
      child: _buildMarkerIcon(), // Xây dựng icon của marker
    );
  }

//////////////////////////
//   Widget _buildMarkerIcon() {
//     List<String> latLng = widget.marker.latitudeLongitude.split(', ');
//     LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
//     double distance = _calculateDistance(widget.currentPosition, markerPosition);
//
//     var flutterTtsCustom = FlutterTtsCustom();
//     double iconSize = 40.0;
//
//     Widget locationIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
//
//     if (widget.marker.level == 1) {
//       locationIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
//     } else if (widget.marker.level == 2) {
//       locationIcon = Icon(Icons.location_on, color: Colors.orange, size: iconSize);
//     } else {
//       if (distance <= 1000) {
//         locationIcon = Icon(Icons.location_on, color: Colors.black, size: iconSize);
//       } else {
//         locationIcon = Icon(Icons.location_on, color: Colors.red, size: iconSize);
//       }
//     }
//
//
//
//     Widget cloudIcon = const SizedBox.shrink();
//
//     if (widget.marker.mua) {
//       cloudIcon = const Icon(
//         Icons.cloud,
//         color: Colors.grey,
//         size: 30.0,
//       );
//     }
//
//     if (distance <= 1000 && !isSpeaking) {
//       // Bắt đầu phát âm thanh 60s một lần nếu chưa phát
//       flutterTtsCustom.startSpeaking('Cảnh báo đã tiến vào khu vực có mực nước bị ngập cấp: ${widget.marker.level}');
//       setState(() {
//         isSpeaking = true; // Cập nhật trạng thái
//       });
//     } else if (distance > 1000 && isSpeaking) {
//       // Dừng phát âm thanh nếu khoảng cách lớn hơn 1000 và đang phát
//       flutterTtsCustom.stopSpeaking();
//       setState(() {
//         isSpeaking = false; // Cập nhật trạng thái
//       });
//     }
//     if (widget.marker.level==1) {
//       cloudIcon = const Icon(
//         Icons.waves,
//         color: Colors.orangeAccent,
//         size: 30.0,
//       );
//     } else if (widget.marker.level==2) {
//       cloudIcon = const Icon(
//         Icons.waves,
//         color: Colors.orange,
//         size: 30.0,
//       );
//     } else if (widget.marker.level==3) {
//       cloudIcon = const Icon(
//         Icons.waves,
//         color: Colors.red,
//         size: 30.0,
//       );
//     }
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           height: (iconSize / 2),
//           child: Center(child: cloudIcon),
//         ),
//         SizedBox(
//           height: iconSize,
//           child: locationIcon,
//         ),
//       ],
//     );
//   }

  Widget _buildMarkerIcon() {
    List<String> latLng = widget.marker.latitudeLongitude.split(', ');
    LatLng markerPosition =
        LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
    double distance =
        _calculateDistance(widget.currentPosition, markerPosition);

    var flutterTtsCustom = FlutterTtsCustom();
    double iconSize = 30.0;

    Widget locationIcon =
        Icon(Icons.location_on, color: Colors.blue, size: iconSize);
    if (widget.marker.level == 1) {
      locationIcon =
          Icon(Icons.location_on, color: Colors.yellowAccent, size: iconSize);
    } else if (widget.marker.level == 2) {
      locationIcon =
          Icon(Icons.location_on, color: Colors.orange, size: iconSize);
    } else {
      if (distance <= 1000) {
        locationIcon =
            Icon(Icons.location_on, color: Colors.black, size: iconSize);
      } else {
        locationIcon =
            Icon(Icons.location_on, color: Colors.red, size: iconSize);
      }
    }

    Widget cloudIcon = const SizedBox.shrink();
    if (widget.marker.mua) {
      cloudIcon = const Padding(
        padding: EdgeInsets.only(right: 5.0),
        child: Icon(
          Icons.cloud,
          color: Colors.grey,
          size: 30.0,
        ),
      );
    }

    Widget floodIcon = const SizedBox.shrink();
      if (widget.marker.waterDepth<=30 && widget.marker.waterDepth>0) {
        //thêm padding để icon không bị cắt
        floodIcon = const Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(Icons.waves, color: Colors.yellowAccent, size: 30.0),
        );
      }else if (widget.marker.level == 1) {
      //thêm padding để icon không bị cắt
      floodIcon = const Padding(
        padding: EdgeInsets.only(left: 5.0),
        child: Icon(Icons.waves, color: Colors.yellowAccent, size: 30.0),
      );
    } else if (widget.marker.level == 2) {
      floodIcon = const Padding(
        padding: EdgeInsets.only(left: 5.0),
        child: Icon(Icons.waves, color: Colors.orange, size: 30.0),
      );
    } else if (widget.marker.level == 3) {
      floodIcon = const Padding(
        padding: EdgeInsets.only(left: 5.0),
        child: Icon(Icons.waves, color: Colors.red, size: 30.0),
      );

    }
    if (distance <= 1000 && !isSpeaking) {
      // Bắt đầu phát âm thanh 60s một lần nếu chưa phát
      flutterTtsCustom.startSpeaking(
          'Cảnh báo đã tiến vào khu vực có mực nước bị ngập cấp: ${widget.marker.level},${widget.marker.other}');
      setState(() {
        isSpeaking = true; // Cập nhật trạng thái
      });
    } else if (distance > 1000 && isSpeaking) {
      // Dừng phát âm thanh nếu khoảng cách lớn hơn 1000 và đang phát
      flutterTtsCustom.stopSpeaking();
      setState(() {
        isSpeaking = false; // Cập nhật trạng thái
      });
    }
    //Sử dụng Expanded hoặc Flexible để đảm bảo các widget phù hợp với kích thước của container cha:
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.marker.mua == true) Expanded(child: cloudIcon),
            if (widget.marker.level > 0) Expanded(child: floodIcon),
          ],
        ),
        Expanded(child: locationIcon),
      ],
    );
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371000;
    double lat1 = pos1.latitude * pi / 180;
    double lon1 = pos1.longitude * pi / 180;
    double lat2 = pos2.latitude * pi / 180;
    double lon2 = pos2.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = R * c;
    return distance;
  }

  void _showMarkerInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // tiêu đề căn giữa, size 20, nền chữ màu trắng
          title: const Text('THÔNG TIN KHU VỰC HIỆN TẠI',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  backgroundColor: Colors.white)),
          // backgroundColor: Colors.grey[500],
        content: Container(
        width: 400, // Chiều rộng tùy chỉnh cho hộp thoại
        height: 250, // Chiều cao tùy chỉnh cho hộp thoại
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.marker.level == 1)
                Row(
                  children: [
                    const Icon(Icons.water, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text('Mực nước thấp,\ncảnh báo cấp: ${widget.marker.level}',
                        style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              if (widget.marker.level == 2)
                Row(
                  children: [
                    const Icon(Icons.water, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                        'Mực nước trung bình,\ncảnh báo cấp: ${widget.marker.level} ',
                        style: const TextStyle(color: Colors.orange)),
                  ],
                ),
              if (widget.marker.level == 3)
                Row(
                  children: [
                    const Icon(Icons.water, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text('Mực nước cao,\n cảnh báo cấp: ${widget.marker.level}',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              // const SizedBox(height: 8),
              // Row(
              //   children: [
              //     const Icon(Icons.water_drop, color: Colors.blue, size: 20),
              //     const SizedBox(width: 8),
              //     Text('Cảnh báo ngập lụt cấp: ${widget.marker.level}', style: const TextStyle(color: Colors.blue)),
              //   ],
              // ),
              // const SizedBox(height: 8),

              const SizedBox(height: 8),
              if (widget.marker.waterDepth<=30 && widget.marker.waterDepth>0)
                Row(
                  children: [
                    const Icon(Icons.privacy_tip, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text('Độ cao nước: ${widget.marker.waterDepth} cm',
                        style: const TextStyle(color: Colors.blue)),
                  ],
                )
             else if (widget.marker.level == 1)
                Row(
                  children: [
                    const Icon(Icons.privacy_tip, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text('Độ cao nước: ${widget.marker.waterDepth} cm',
                        style: const TextStyle(color: Colors.blue)),
                  ],
                )
              else if (widget.marker.level == 2)
                Row(
                  children: [
                    const Icon(Icons.privacy_tip, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text('Độ cao nước: ${widget.marker.waterDepth} cm',
                        style: const TextStyle(color: Colors.orange)),
                  ],
                )
              else if (widget.marker.level == 3)
                Row(
                  children: [
                    const Icon(Icons.privacy_tip, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text('Độ cao nước: ${widget.marker.waterDepth} cm',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),

              // const SizedBox(height: 8),
              // Mưa
              // if (widget.marker.mua)
              //   const Row(
              //     children: [
              //       Icon(Icons.cloud, color: Colors.grey, size: 20),
              //       SizedBox(width: 8),
              //       Text('Đang có mưa', style: TextStyle(color: Colors.grey)),
              //     ],
              //   )
              // else
              //   const Row(
              //     children: [
              //       Icon(Icons.cloud_off, color: Colors.grey, size: 20),
              //       SizedBox(width: 8),
              //       Text('Không mưa', style: TextStyle(color: Colors.grey)),
              //     ],
              //   ),
              // const SizedBox(height: 8),
              // Row(
              //   children: [
              //     const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 20),
              //     const SizedBox(width: 8),
              //     Text('Chỉ số UV: ${widget.marker.uv}'),
              //   ],
              // ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('Thông tin khác: ${widget.marker.other}')),
                ],
              ),
            ],
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:mobile/model/markerss.dart';
// import 'package:mobile/widgets/animation_custom.dart';
// import 'package:mobile/services/flutter_tts_custom.dart';
//
// class IconMarkersCustomDrawer extends StatelessWidget {
//   // final LatLng currentPosition; // Vị trí hiện tại của người dùng
//   // final Markerss marker; // Thông tin của marker
//   //
//   // const IconMarkersCustomDrawer({
//   //   super.key,
//   //   required this.currentPosition,test@gmail.com
//   //   required this.marker,
//   // });
//   // bool oneShot = true;
//
//   final LatLng currentPosition; // Vị trí hiện tại của người dùng
//   final Markerss marker; // Thông tin của marker
//
//   IconMarkersCustomDrawer({
//     super.key,
//     required this.currentPosition,
//     required this.marker,
//   });
//   // Widget _buildMarkerIcon() {
//   //   List<String> latLng = marker.latitudeLongitude.split(', ');
//   //   LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
//   //   double distance = _calculateDistance(currentPosition, markerPosition);
//   //
//   //   // Define the icon size
//   //   double iconSize = 40.0;
//   //
//     // Build the bottom half with the location_on icon
// //     Widget bottomIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
// //
// //     if (marker.level == 1) {
// //       bottomIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
// //     } else if (marker.level == 2) {
// //       bottomIcon = Icon(Icons.location_on, color: Colors.orange, size: iconSize);
// //     } else {
// //       if (distance <= 1000) {
// //         bottomIcon = Icon(Icons.location_on, color: Colors.black, size: iconSize);
// //       } else {
// //         bottomIcon = Icon(Icons.location_on, color: Colors.red, size: iconSize);
// //       }
// //     }
// //
// //     // Build the top half based on whether there is rain (marker.mua)
// //     Widget topIcon = const SizedBox.shrink(); // Empty widget if no rain
// //
// //     // if (marker.mua) {
// // // //   stackChildren.add(const Positioned(
// // // //     top: -20, // Adjust this value to move the cloud icon higher without cutting it off
// // // //     child: Padding(
// // // //       padding: EdgeInsets.only(bottom: 5.0),
// // // //       child: Icon(Icons.cloud, color: Colors.grey, size: 30.0),
// // // //     ),
// // // //   ));
// // // // }
// // //     if (marker.level > 2) {
// // //       t.add(AnimationCustom());
// // //     }
// //     if (marker.mua) {
// //       topIcon = const Padding(
// //         padding: EdgeInsets.only(bottom: 1.0),
// //         child: Icon(
// //           Icons.cloud,
// //           color: Colors.grey,
// //           size: 30.0,
// //         ),
// //       ); // Show cloud icon if it rains
// //     }
// //
// //     return Column(
// //       mainAxisSize: MainAxisSize.min, // Ensure the column doesn't expand unnecessarily
// //       children: [
// //         // Top half
// //         SizedBox(
// //           height: (iconSize / 2)-15, // Half the height of the icon
// //           child: Center(child: topIcon), // Center the cloud icon if it exists, or empty
// //         ),
// //
// //         // Bottom half
// //         SizedBox(
// //           height: iconSize+5, // Full height of the location_on icon
// //           child: bottomIcon, // Show the location_on icon
// //         ),
// //       ],
// //     );
// //   }
//   bool isSpeaking = false; // Biến trạng thái
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showMarkerInfo(context), // Hiển thị thông tin marker khi nhấn vào
//       child: _buildMarkerIcon(), // Xây dựng icon của marker
//     );
//   }
//
//   Widget _buildMarkerIcon() {
//     List<String> latLng = marker.latitudeLongitude.split(', ');
//     LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
//     double distance = _calculateDistance(currentPosition, markerPosition);
//
//     var flutterTtsCustom = FlutterTtsCustom();
//     // Define the icon size
//     double iconSize = 40.0;
//
//     // Build the location_on icon (it will be on top of the cloud)test@gmail.com
//     Widget locationIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
//
//     if (marker.level == 1) {
//       locationIcon = Icon(Icons.location_on, color: Colors.blue, size: iconSize);
//     } else if (marker.level == 2) {
//       locationIcon = Icon(Icons.location_on, color: Colors.orange, size: iconSize);
//     } else {
//       if (distance <= 1000) {
//
//         locationIcon = Icon(Icons.location_on, color: Colors.black, size: iconSize);
//       } else {
//         locationIcon = Icon(Icons.location_on, color: Colors.red, size: iconSize);
//       }
//     }
//     if (distance <= 1000 && !isSpeaking) {
//       // Bắt đầu phát âm thanh 60s một lần nếu chưa phát
//       flutterTtsCustom.startSpeakingPeriodically('Cảnh báo mực nước cấp: ${marker.level}');
//       isSpeaking = true; // Cập nhật trạng thái
//     } else if (distance > 1000 && isSpeaking) {
//       // Dừng phát âm thanh nếu khoảng cách lớn hơn 1000 và đang phát
//       flutterTtsCustom.stopSpeaking();
//       isSpeaking = false; // Cập nhật trạng thái
//     }
//     // Build the cloud icon (it will be below the location icon)
//     Widget cloudIcon = const SizedBox.shrink(); // Empty widget if no rain
//
//     if (marker.mua) {
//       cloudIcon = const Icon(
//         Icons.cloud,
//         color: Colors.grey,
//         size: 30.0,
//       ); // Show cloud icon if it rains
//     }
//
//     return Column(
//       mainAxisSize: MainAxisSize.min, // Ensure the column doesn't expand unnecessarily
//       children: [
//         // Bottom half (cloud icon)
//         SizedBox(
//           height: (iconSize / 2), // Half the height of the icon
//           child: Center(child: cloudIcon), // Center the cloud icon if it exists, or empty
//         ),
//
//         // Top half (location_on icon)
//         SizedBox(
//           height: iconSize, // Full height of the location_on icon
//           child: locationIcon, // Show the location_on icon
//         ),
//       ],
//     );
//   }
//
//
//
// //   Widget _buildMarkerIcon() {
// //     List<String> latLng = marker.latitudeLongitude.split(', ');
// //     LatLng markerPosition = LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
// //     double distance = _calculateDistance(currentPosition, markerPosition);
// //
// //     Widget icon = Icon(Icons.location_on, color: Colors.blue, size: 40.0);
// //
// //     if (marker.level == 1) {
// //       icon = Icon(Icons.location_on, color: Colors.blue, size: 40.0);
// //     } else if (marker.level == 2) {
// //       icon = Icon(Icons.location_on, color: Colors.orange, size: 40.0);
// //     } else {
// //       if (distance <= 1000) {
// //         icon = Icon(Icons.location_on, color: Colors.black, size: 40.0);
// //       } else {
// //         icon = Icon(Icons.location_on, color: Colors.red, size: 40.0);
// //       }
// //     }
// //
// //     List<Widget> stackChildren = [icon];
// //
// //     if (marker.level > 2) {
// //       stackChildren.add(AnimationCustom());
// //     }
// //
// // //     if (marker.mua) {
// // //   stackChildren.add(const Positioned(
// // //     top: -20, // Adjust this value to move the cloud icon higher without cutting it off
// // //     child: Padding(
// // //       padding: EdgeInsets.only(bottom: 5.0),
// // //       child: Icon(Icons.cloud, color: Colors.grey, size: 30.0),
// // //     ),
// // //   ));
// // // }
// //     if (marker.mua) {
// //       stackChildren.add(
// //         Positioned(
// //           top: -20, // Keep the negative top value to move the cloud icon higher
// //           child: OverflowBox(
// //             maxHeight: 90.0, // Adjust this value to give enough space for the icon to overflow
// //             child: Padding(
// //               padding: const EdgeInsets.only(bottom: 5.0),
// //               child: Icon(Icons.cloud, color: Colors.grey, size: 30.0),
// //             ),
// //           ),
// //         ),
// //       );
// //     }
// //
// //     return Stack(
// //       alignment: Alignment.center,
// //       children: stackChildren,
// //     );
// //   }
//
//   double _calculateDistance(LatLng pos1, LatLng pos2) {
//     const double R = 6371000; // Bán kính Trái đất theo mét
//     double lat1 = pos1.latitude * pi / 180; // Chuyển vĩ độ từ độ sang radian
//     double lon1 = pos1.longitude * pi / 180; // Chuyển kinh độ từ độ sang radian
//     double lat2 = pos2.latitude * pi / 180;
//     double lon2 = pos2.longitude * pi / 180;
//
//     double dLat = lat2 - lat1; // Chênh lệch vĩ độ
//     double dLon = lon2 - lon1; // Chênh lệch kinh độ
//
//     // Công thức Haversine để tính khoảng cách giữa hai điểm trên bề mặt Trái đất
//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//
//     double distance = R * c; // Khoảng cách theo mét
//     return distance;
//   }
//
//   void _showMarkerInfo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Thông tin thiết bị'), // Tiêu đề của hộp thoại
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Level: ${marker.level}'), // Hiển thị level của marker
//               Text('Other: ${marker.other}'), // Hiển thị thông tin khác của marker
//               Text('Mua: ${marker.mua}'), // Hiển thị thông tin mưa
//               Text('Ngap: ${marker.ngap}'), // Hiển thị thông tin ngập
//               Text('Water Depth: ${marker.waterDepth} cm'), // Hiển thị độ sâu nước
//               Text('UV: ${marker.uv}'), // Hiển thị chỉ số UV
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(), // Đóng hộp thoại khi nhấn nút
//               child: const Text('Đóng'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
