import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:mobile/screen/home_screen.dart';
import 'package:mobile/screen/error_warning.dart';



class BottomAppBarWidget extends StatelessWidget {
  final Function(int) onTabSelected;

  const BottomAppBarWidget({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.react,
      items: const [
        TabItem(icon: Icons.list, title: 'Danh sách'),
        TabItem(icon: Icons.map, title: 'Map'),
        TabItem(icon: Icons.warning, title: 'Báo cáo sự cố'),
      ],
      initialActiveIndex: 1, // optional, default as 1
      onTap: onTabSelected,
    );
  }
}



// class BottomAppBarWidget extends StatelessWidget {
//   const BottomAppBarWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ConvexAppBar(
//       style: TabStyle.react,
//       items: const [
//         TabItem(icon: Icons.list, title: 'Danh sách các trạm'),
//         TabItem(icon: Icons.map, title: 'Map'),
//         TabItem(icon: Icons.warning, title: 'Báo cáo sự cố'),
//       ],
//       initialActiveIndex: 1, // optional, default as 0
//       onTap: (int i) {
//         if (i==0){
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const HomeScreen()),
//           );
//         }
//         else if (i == 1) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const HomeScreen()),
//           );
//         } else if (i == 2) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const ErrorWarning()),
//           );
//         }
//       },
//     );
//   }
// }