class MarkersReports {
  final String ngayThangNam;
  final String email;
  final bool hieuLuc;
  final String hinhAnh1;
  final String hinhAnh2;
  final String hoVaTen;
  final String latitudeLongitude;
  final String linkFaceId;
  final String loaiSuCo;
  final int namsinh;
  final String noiDung;
  final String sdt;
  final String thoiGian;
  final String uid;

  MarkersReports({
    required this.ngayThangNam,
    required this.email,
    required this.hieuLuc,
    required this.hinhAnh1,
    required this.hinhAnh2,
    required this.hoVaTen,
    required this.latitudeLongitude,
    required this.linkFaceId,
    required this.loaiSuCo,
    required this.namsinh,
    required this.noiDung,
    required this.sdt,
    required this.thoiGian,
    required this.uid,
  });

  /// Chuyển đổi từ Map (JSON) thành đối tượng MarkersReports
  factory MarkersReports.fromJson(Map<String, dynamic> json) {
    return MarkersReports(
      ngayThangNam: json['ngayThangNam'],
      email: json['email'],
      hieuLuc: json['hieuLuc'],
      hinhAnh1: json['hinhAnh1'],
      hinhAnh2: json['hinhAnh2'],
      hoVaTen: json['hoVaTen'],
      latitudeLongitude: json['latitudeLongitude'],
      linkFaceId: json['linkFaceId'],
      loaiSuCo: json['loaiSuCo'],
      namsinh: json['namsinh'],
      noiDung: json['noiDung'],
      sdt: json['sdt'],
      thoiGian: json['thoiGian'],
      uid: json['uid'],
    );
  }

  /// Chuyển đổi đối tượng MarkersReports thành Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'ngayThangNam': ngayThangNam,
      'email': email,
      'hieuLuc': hieuLuc,
      'hinhAnh1': hinhAnh1,
      'hinhAnh2': hinhAnh2,
      'hoVaTen': hoVaTen,
      'latitudeLongitude': latitudeLongitude,
      'linkFaceId': linkFaceId,
      'loaiSuCo': loaiSuCo,
      'namsinh': namsinh,
      'noiDung': noiDung,
      'sdt': sdt,
      'thoiGian': thoiGian,
      'uid': uid,
    };
  }
}
