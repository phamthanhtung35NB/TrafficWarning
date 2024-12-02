//file user_reports.dart
import 'dart:ffi';

class UserReports {
  String _uid="";
   String _email="";
   String _hoVaTen="";
   String _linkFaceId="";
   int _namsinh=0;
   String _sdt="";
   String _loaiSuCo="";
   String _latitudeLongitude="";
   String _noiDung="";
   String _thoiGian="";
   String _ngayThangNam="";
   String _hinhAnh1="";
   String _hinhAnh2="";
   bool _hieuLuc=true;

  UserReports(
      this._uid,
      this._email,
      this._hoVaTen,
      this._linkFaceId,
      this._namsinh,
      this._sdt,
      this._loaiSuCo,
      this._latitudeLongitude,
      this._noiDung,
      this._thoiGian,
      this._ngayThangNam,
      this._hinhAnh1,
      this._hinhAnh2,
      this._hieuLuc
      );

  bool get hieuLuc => _hieuLuc;

  set hieuLuc(bool value) {
    _hieuLuc = value;
  }
  String get hinhAnh2 => _hinhAnh2;

  set hinhAnh2(String value) {
    _hinhAnh2 = value;
  }

  String get hinhAnh1 => _hinhAnh1;

  set hinhAnh1(String value) {
    _hinhAnh1 = value;
  }

  String get ngayThangNam => _ngayThangNam;

  set ngayThangNam(String value) {
    _ngayThangNam = value;
  }

  String get thoiGian => _thoiGian;

  set thoiGian(String value) {
    _thoiGian = value;
  }

  String get noiDung => _noiDung;

  set noiDung(String value) {
    _noiDung = value;
  }

  String get latitudeLongitude => _latitudeLongitude;

  set latitudeLongitude(String value) {
    _latitudeLongitude = value;
  }

  String get loaiSuCo => _loaiSuCo;

  set loaiSuCo(String value) {
    _loaiSuCo = value;
  }

  String get sdt => _sdt;

  set sdt(String value) {
    _sdt = value;
  }

  int get namsinh => _namsinh;

  set namsinh(int value) {
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