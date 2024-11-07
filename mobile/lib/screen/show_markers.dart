// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
//
// class ShowMarkers extends StatelessWidget {
//   final List<Marker> markers;
//
//   const ShowMarkers({super.key, required this.markers});
//
//   @override
//   Widget build(BuildContext context) {
//     return FlutterMap(
//       options: MapOptions(
//         center: LatLng(21.038859, 105.785613),
//         zoom: 13.0,
//       ),
//       children: [
//         TileLayer(
//           urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//           subdomains: const ['a', 'b', 'c'],
//         ),
//         MarkerLayer(markers: markers),
//       ],
//     );
//   }
// }