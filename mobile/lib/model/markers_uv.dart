class MarkersUV {
  final  double uv;
  final String latitudeLongitude;

  MarkersUV({
    required this.uv,
    required this.latitudeLongitude,
  });

  factory MarkersUV.fromJson(Map<String, dynamic> json) {
    // Kiểm tra và chuyển đổi giá trị uv sang double nếu cần
    double uvValue;
    if (json['uv'] is int) {
      uvValue = (json['uv'] as int).toDouble();
    } else if (json['uv'] is double) {
      uvValue = json['uv'];
    } else {
      uvValue = 0.0; // Giá trị mặc định nếu không có hoặc không phải số
    }

    return MarkersUV(
      uv: uvValue,
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