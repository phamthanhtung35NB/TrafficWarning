import 'package:flutter_tts/flutter_tts.dart'; // Sửa Dart thành dart
import 'dart:async';

class FlutterTtsCustom {

  final FlutterTts flutterTts = FlutterTts();
  Timer? _timer; // Khởi tạo Timer
  Future<void> speak(String text) async {
    try {
      await flutterTts.stop(); // Dừng trước khi nói đoạn mới
      await flutterTts.speak(text);
    } catch (e) {
      print("Error: $e");
    }
  }

  void startSpeaking(String text ) {
    speak(text);
  }
  void startSpeakingPeriodically(String text ,int milisecondss) {
    if (_timer != null && _timer!.isActive) return; // Nếu timer đang chạy, không khởi động lại

    // Thiết lập hẹn giờ phát âm mỗi 60 giây
    _timer = Timer.periodic(Duration(milliseconds: milisecondss), (timer) {
      speak(text);
    });

    // Phát lần đầu ngay lập tức
    speak(text);
  }
  Future<void> stopSpeaking() async {
    await flutterTts.stop();
  }
  void stopSpeakingPeriodically() {
    // Hủy timer khi không cần phát nữa
    _timer?.cancel();
    _timer = null;
  }
}


