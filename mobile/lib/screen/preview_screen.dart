import 'dart:io';

import 'package:flutter/material.dart';

class PreviewScreen extends StatelessWidget {
  final String imagePath;

  PreviewScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xem trước ảnh'),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
    // Your widget code here
  }
}