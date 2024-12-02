import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email đã được sử dụng.';
      } else if (e.code == 'weak-password') {
        return 'Mật khẩu quá yếu.';
      } else {
        return 'Đã xảy ra lỗi. Vui lòng thử lại: ${e.message}';
      }
    } catch (e) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại: ${e.toString()}';
    }
  }

  Future<String?> registerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Đăng ký Google đã bị hủy.';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user?.uid;
    } catch (e) {
      return 'Đã xảy ra lỗi khi đăng ký bằng Google: ${e.toString()}';
    }
  }


}