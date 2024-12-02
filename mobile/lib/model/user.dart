//đối tượng User
import 'dart:ffi';

class User {
  late String _uid = '';
  String _email='';
  String _hoVaTen = '';
  String _linkFaceId = '';
  int _namsinh = 0;
  String _sdt = '';
  Bool _authenticated = false as Bool;


  User(this._uid, this._email, this._hoVaTen, this._linkFaceId, this._namsinh,
      this._sdt, this._authenticated);

  User.fromJson(Map<String, dynamic> json) {
    _uid = json['uid'];
    _email = json['email'];
    _hoVaTen = json['hoVaTen'];
    _linkFaceId = json['linkFaceId'];
    _namsinh = json['tuoi'];
    _sdt = json['sdt'];
    _authenticated = json['authenticated'];
  }

  Bool get authenticated => _authenticated;

  set authenticated(Bool value) {
    _authenticated = value;
  }

  String get sdt => _sdt;

  set sdt(String value) {
    _sdt = value;
  }

  int get tuoi => _namsinh;

  set tuoi(int value) {
    _namsinh = value;
  }

  String get linkFaceId => _linkFaceId;

  set linkFaceId(String value) {
    _linkFaceId = value;
  }

  String get hoVaTen => _hoVaTen;

  set hoVaTen(String value) {
    _hoVaTen = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get uid => _uid;

  set uid(String value) {
    _uid = value;
  }
}