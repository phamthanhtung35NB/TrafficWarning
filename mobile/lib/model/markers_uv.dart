class MarkersUV {
  final  double uv;
  final String latitudeLongitude;

  MarkersUV({
    required this.uv,
    required this.latitudeLongitude,
  });

  factory MarkersUV.fromJson(Map<String, dynamic> json) {
    return MarkersUV(
      uv: json['uv'],
      latitudeLongitude: json['latitudeLongitude'],
    );
  }

  toMap() {
    return {
      'uv': uv,
      'latitudeLongitude': latitudeLongitude,
    };
  }
}