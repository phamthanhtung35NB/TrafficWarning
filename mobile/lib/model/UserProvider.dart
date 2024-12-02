import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _uid = '';
  String _email = '';
  String _hoVaTen = '';
  String _linkFaceId = '';
  int _namsinh = 0;
  String _sdt = '';
  bool _authenticated = false;

  String get uid => _uid;
  String get email => _email;
  String get hoVaTen => _hoVaTen;
  String get linkFaceId => _linkFaceId;
  int get namsinh => _namsinh;
  String get sdt => _sdt;
  bool get authenticated => _authenticated;

  void setUserInfo({
    required String uid,
    required String email,
    required String hoVaTen,
    required String linkFaceId,
    required int namsinh,
    required String sdt,
    required bool authenticated,
  }) {
    _uid = uid;
    _email = email;
    _hoVaTen = hoVaTen;
    _linkFaceId = linkFaceId;
    _namsinh = namsinh;
    _sdt = sdt;
    _authenticated = authenticated;
    notifyListeners(); // Để các widget có thể nhận thông báo thay đổi
  }
}
