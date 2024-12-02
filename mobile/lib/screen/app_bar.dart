import 'package:flutter/material.dart';
import 'package:mobile/screen/ProfileScreen.dart';
import 'package:mobile/screen/custom_drawer.dart';
import 'package:provider/provider.dart';

import '../model/UserProvider.dart';

class AppBarScreen extends StatelessWidget implements PreferredSizeWidget {
  const AppBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng từ UserProvider
    var user = Provider.of<UserProvider>(context);
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            child: Text('Xin Chào ${user.hoVaTen}', style: const TextStyle(color: Colors.black)),
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
            icon: const Icon(Icons.account_circle_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}