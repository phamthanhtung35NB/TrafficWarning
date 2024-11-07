class Markerss {
  String latitudeLongitude;
  int level;
  bool mua;
  bool ngap;
  int waterDepth;
  double uv; // Change from int to double
  String other;

  Markerss({
    required this.latitudeLongitude,
    required this.level,
    required this.mua,
    required this.ngap,
    required this.waterDepth,
    required this.uv,
    required this.other,
  });

  factory Markerss.fromJson(Map<String, dynamic> json) {
    return Markerss(
      latitudeLongitude: json['latitudeLongitude'],
      level: json['level'],
      mua: json['mua'],
      ngap: json['ngap'],
      waterDepth: json['waterDepth'],
      uv: json['uv'], // Ensure this is double
      other: json['other'],
    );
  }
}