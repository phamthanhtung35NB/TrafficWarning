import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../model/UserProvider.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> login(BuildContext context, String email, String password) async {
          try {
            // Đăng nhập với email và mật khẩu
            UserCredential userCredential = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
print("1");
            // Lấy UID của người dùng đã đăng nhập
            String uid = userCredential.user!.uid;
            if (uid != null) {
              await _checkOrCreateUserInFirestore(uid, email);
            print("2");
            }
            // Lấy thông tin người dùng từ Firestore
            DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
print("3");
            if (userDoc.exists) {
              print("4");
              var userData = userDoc.data() as Map<String, dynamic>;
              // Lưu thông tin người dùng vào UserProvider
              Provider.of<UserProvider>(context, listen: false).setUserInfo(
                uid: uid,
                email: userData['email'] ?? '',
                hoVaTen: userData['hoVaTen'] ?? '',
                linkFaceId: userData['linkFaceId'] ?? '',
                namsinh: userData['namsinh'] ?? 0,
                sdt: userData['sdt'] ?? '',
                authenticated: userData['authenticated'] ?? false,
              );
              return uid;
            }
          } catch (e) {
            print('Lỗi đăng nhập: ${e.toString()}');
            // Có thể xử lý thông báo lỗi cho người dùng
          }
  }

  Future<String> loginWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Đăng nhập bị hủy
        return"";
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Sau khi đăng nhập, lấy UID và thông tin người dùng từ Firestore
      String uid = userCredential.user!.uid;

      if (uid != null) {
        await _checkOrCreateUserInFirestore(uid, googleUser.email ?? '');
      }
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        // Lưu thông tin người dùng vào UserProvider
        Provider.of<UserProvider>(context, listen: false).setUserInfo(
          uid: uid,
          email: userData['email'] ?? '',
          hoVaTen: userData['hoVaTen'] ?? '',
          linkFaceId: userData['linkFaceId'] ?? '',
          namsinh: userData['namsinh'] ?? 0,
          sdt: userData['sdt'] ?? '',
          authenticated: userData['authenticated'] ?? false,
        );
      }

      return uid;
    } catch (e) {
      print('Lỗi đăng nhập: ${e.toString()}');
      return '';
    }
    return '';
  }

  Future<void> _checkOrCreateUserInFirestore(String uid, String email) async {
    DocumentReference userRef = _firestore.collection('users').doc(uid);

    DocumentSnapshot userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      await userRef.set({
        'uid': uid,
        'email': email,
        'hoVaTen': '',
        'linkFaceId': '',
        'namsinh': 0,
        'sdt': '',
        'authenticated': false,
      });
    }
  }
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> changePassword(String currentPassword, String newPassword) async {
    User? user = _auth.currentUser;

    if (user == null) {
      return 'No user is currently signed in.';
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return 'Mật khẩu đã được cập nhật thành công.';
    } on FirebaseAuthException catch (e) {
      return 'Error: ${e.message}';
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Password reset email has been sent.';
    } on FirebaseAuthException catch (e) {
      return 'Error: ${e.message}';
    } catch (e) {
      return 'An error occurred: ${e.toString()}';
    }
  }
}
