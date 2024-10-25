import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String?> login(String email, String password) async {
    String username = email.split('@')[0];
    // return 'username: $useacrname password: $password';
    if (password==username) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential.user?.uid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return 'Thông tin tài khoản hoặc mật khẩu không chính xác.';
        } else if (e.code == 'weak-password') {
          return 'Mật khẩu cung cấp quá yếu.';
        } else {
          return 'Đã xảy ra lỗi: ${e.message}';
        }
      } catch (e) {
        return 'Đã xảy ra lỗi. Vui lòng thử lại: ${e.toString()}';
      }
    }
    else {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential.user?.uid;
        //không đăng nhập được
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          return 'Không tìm thấy người dùng cho email đó.';
        } else if (e.code == 'wrong-password') {
          return 'Mật khẩu cung cấp không chính xác.';
        } else {
          return 'Đã xảy ra lỗi. Vui lòng thử lại: ${e.message}';
        }
      } catch (e) {
        return 'Đã xảy ra lỗi. Vui lòng thử lại: ${e.toString()}';
      }
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
      // Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update the password
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