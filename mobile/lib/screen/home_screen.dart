// File: lib/screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile/screen/app_bar.dart';
import 'package:mobile/screen/custom_drawer.dart';
import 'package:mobile/screen/bottom_app_bar.dart';
import 'package:mobile/screen/error_warning.dart';
import 'package:mobile/screen/map_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/screen/list_markers_screen.dart';
// import 'package:mobile/screen/user_uthentication.dart';
import 'package:mobile/model/UserProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
  }
  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cảnh báo'),
          content: const Text('Bạn cần xác minh thông tin để thực hiện chức năng này.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    bool isAuthenticated = user.authenticated;

    Widget _getSelectedScreen() {
      switch (_selectedIndex) {
        case 0:
          return ListMarkersScreen();
        case 1:
          return MapScreen();
        case 2:
            return const ErrorWarning();
        default:
          return MapScreen();
      }
    }

    return Scaffold(
      appBar: const AppBarScreen(),
      body: Column(
        children: [
          if (!isAuthenticated)
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 10, left: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 5),
                  const Icon(Icons.warning, color: Colors.red, size: 30),
                  const SizedBox(width: 1),
                  SizedBox(
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
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: const EdgeInsets.only(
                            left: 0, top: 10, bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
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
          Expanded(child: _getSelectedScreen()),
        ],
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: BottomAppBarWidget(
        onTabSelected: (int index) {
          setState(() {
            if (index == 2 && !isAuthenticated) {
              _showWarningDialog(context);
              return;
            }else if (index == 2 && isAuthenticated) {
              _selectedIndex = index;
            } else {
              _selectedIndex = index;
            }
          });
        },
      ),
    );
  }
}
