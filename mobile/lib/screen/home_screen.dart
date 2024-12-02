// File: lib/screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile/screen/app_bar.dart';
import 'package:mobile/screen/custom_drawer.dart';
import 'package:mobile/screen/bottom_app_bar.dart';
import 'package:mobile/screen/map_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/screen/user_uthentication.dart';
import 'package:mobile/model/UserProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    bool isAuthenticated = user.authenticated;
    return Scaffold(
      appBar: const AppBarScreen(),
      body: Column(
        children: [
          if (!isAuthenticated)
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 10,left: 0),
              child: Row(
                //vừa căn trái vừa căn dọc

                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 5),
                  const Icon(Icons.warning, color: Colors.red, size: 30),
                  const SizedBox(width: 1),
                  SizedBox(
                    //70% of screen width
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: const Text(
                      'Cảnh báo: Bạn chưa xác minh thông tin.\nVui lòng cập nhật thông tin.',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    //30% of screen width
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: ElevatedButton(
                      //kích thước nút
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.only(
                            left: 0, top: 10, bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        // Navigate to Update Profile screen
                        Navigator.pushNamed(context, '/user_uthentication');
                      },
                      child: const Text(
                        'Cập nhật\n thông tin ngay',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: MapScreen()),
        ],
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: const BottomAppBarWidget(),
    );
  }
}
