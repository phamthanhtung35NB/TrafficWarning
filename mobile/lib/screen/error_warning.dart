import 'package:flutter/material.dart';
import 'package:mobile/controller/error_warning_controller.dart';

class ErrorWarning extends StatelessWidget {
  const ErrorWarning({super.key});

  @override
  Widget build(BuildContext context) {
    // 1 edit text
    // 2 button

    print('ErrorWarning build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Warning'),
      ),
      body: ListView(
        children: <Widget>[
          const Text('Error Warning'),
          ElevatedButton(
            onPressed: () {
            },
            child: const Text('Show Error Warning'),
          ),
        ],
      ),
    );

  }
}