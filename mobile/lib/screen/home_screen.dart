// File: lib/screen/home_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile/screen/app_bar.dart';
import 'package:mobile/screen/custom_drawer.dart';
import 'package:mobile/screen/bottom_app_bar.dart';
import 'package:mobile/screen/map_screen.dart';

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
    return Scaffold(
      appBar: const AppBarScreen(),
      body: MapScreen(),
      drawer: const CustomDrawer(),
      bottomNavigationBar: const BottomAppBarWidget(),
    );
  }
}