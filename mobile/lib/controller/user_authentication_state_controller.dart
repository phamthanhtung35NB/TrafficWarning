import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuthenticationStateController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm để cập nhật thông tin người dùng vào Firestore
  Future<String> updateUserInfo({
    required String uid,
    required String hoVaTen,
    required String sdt,
    required String namsinh,
    required String linkFaceId,
  }) async {
    try {
      // Tạo map chứa dữ liệu người dùng
      Map<String, dynamic> userData = {
        'hoVaTen': hoVaTen,
        'sdt': sdt,
        'namsinh': namsinh,
        'linkFaceId': linkFaceId,
        'authenticated': true, // Đánh dấu đã xác thực
      };

      // Cập nhật thông tin vào Firestore
      await _firestore.collection('users').doc(uid).update(userData);

      return 'Cập nhật thông tin thành công';
    } catch (e) {
      return 'Lỗi khi cập nhật thông tin: ${e.toString()}';
    }
  }

  // Hàm để xử lý đăng nhập hoặc tạo tài khoản mới và lưu thông tin người dùng
  Future<String> handleLoginAndUpdateInfo({
    required String email,
    required String password,
    required String hoVaTen,
    required String sdt,
    required String namsinh,
    required String linkFaceId,
  }) async {
    try {
      // Đăng nhập với email và mật khẩu
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy UID của người dùng sau khi đăng nhập
      String uid = userCredential.user!.uid;

      // Cập nhật thông tin người dùng vào Firestore
      String updateStatus = await updateUserInfo(
        uid: uid,
        hoVaTen: hoVaTen,
        sdt: sdt,
        namsinh: namsinh,
        linkFaceId: linkFaceId,
      );

      return updateStatus;
    } catch (e) {
      return 'Lỗi khi đăng nhập hoặc cập nhật thông tin: ${e.toString()}';
    }
  }

  // Hàm để tạo người dùng mới và lưu thông tin người dùng vào Firestore
  Future<String> createUserAndUpdateInfo({
    required String email,
    required String password,
    required String hoVaTen,
    required String sdt,
    required String namsinh,
    required String linkFaceId,
  }) async {
    try {
      // Tạo tài khoản người dùng mới với email và mật khẩu
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lấy UID của người dùng vừa tạo
      String uid = userCredential.user!.uid;

      // Cập nhật thông tin người dùng vào Firestore
      String updateStatus = await updateUserInfo(
        uid: uid,
        hoVaTen: hoVaTen,
        sdt: sdt,
        namsinh: namsinh,
        linkFaceId: linkFaceId,
      );

      return updateStatus;
    } catch (e) {
      return 'Lỗi khi tạo người dùng và cập nhật thông tin: ${e.toString()}';
    }
  }
}
