import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/user_reports.dart';
//fire basedb.dart
class Firebasedb {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get all devices once
  Future<Map<String, dynamic>> fetchDevices() async {
    DatabaseEvent event = await _database.child('devices').once();
    if (event.snapshot.exists) {
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    } else {
      return {};
    }
  }

  // Listen to device changes in real-time
void listenToDeviceChanges(void Function(Map<String, dynamic>) onData) {
  _database.child('devices').onValue.listen((event) {
    if (event.snapshot.exists) {
      onData(Map<String, dynamic>.from(event.snapshot.value as Map));
    } else {
      onData({});
    }
  });
}
  Future<String> uploadImage(String filePath, String uid, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('imageReports/$uid/$fileName');
      File file = File(filePath);

      await imageRef.putFile(file);

      // Lấy link tải ảnh sau khi tải lên
      return await imageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> saveUserReport(UserReports report) async {
    final databaseRef = FirebaseDatabase.instance.ref();
    final reportRef = databaseRef.child('imageReports/${report.uid}/${report.ngayThangNam}');

    await reportRef.set({
      'uid': report.uid,
      'email': report.email,
      'hoVaTen': report.hoVaTen,
      'linkFaceId': report.linkFaceId,
      'namsinh': report.namsinh,
      'sdt': report.sdt,
      'loaiSuCo': report.loaiSuCo,
      'latitudeLongitude': report.latitudeLongitude,
      'noiDung': report.noiDung,
      'thoiGian': report.thoiGian,
      'ngayThangNam': report.ngayThangNam,
      'hinhAnh1': report.hinhAnh1,
      'hinhAnh2': report.hinhAnh2,
      'hieuLuc': report.hieuLuc,
    });
  }
}