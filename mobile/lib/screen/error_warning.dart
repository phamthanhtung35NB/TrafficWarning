import 'package:flutter/material.dart';
import 'package:mobile/controller/error_warning_controller.dart';

class ErrorWarning extends StatelessWidget {
  const ErrorWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Báo cáo sự cố')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //button lấy vị trí tạo ộ hiện tại
            ElevatedButton(
              onPressed: () {
                ErrorWarningController().showError(context, 'Đã xảy ra lỗi');
              },
              child: const Text('Hiển thị lỗi'),
            ),
            //
            ElevatedButton(
              onPressed: () {
                ErrorWarningController().showError(context, 'An error occurred');
              },
              child: const Text('Show Error'),
            ),
            ElevatedButton(
              onPressed: () {
                ErrorWarningController().showWarning(context, 'Warning: This is a warning message');
              },
              child: const Text('Show Warning'),
            ),
          ],
        ),
      ),
    );
  }
}