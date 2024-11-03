import 'package:flutter/material.dart';
import 'package:mobile/screen/custom_drawer.dart';

class AppBarScreen extends StatelessWidget implements PreferredSizeWidget {
  const AppBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      title: Row(
        children: [
          TextButton(
            child: const Text("Home", style: TextStyle(color: Colors.white)),
            onPressed: () {
              // Navigate to Home screen
            },
          )
        ],
      ),
      actions: [
        Container(
          width: 40,
          height: 40,
          color: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to Notifications screen
            },
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}