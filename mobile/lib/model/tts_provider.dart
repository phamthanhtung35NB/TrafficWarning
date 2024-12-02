import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

class TTSProvider with ChangeNotifier {
  late FlutterTts flutterTts;

  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  String language = 'vi-VN';

  TTSProvider() {
    initTTS();
  }

  Future<void> initTTS() async {
    flutterTts = FlutterTts();
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setLanguage(language);
  }

  Future<void> setVolume(double newVolume) async {
    volume = newVolume;
    await flutterTts.setVolume(volume);
    notifyListeners();
  }

  Future<void> setPitch(double newPitch) async {
    pitch = newPitch;
    await flutterTts.setPitch(pitch);
    notifyListeners();
  }

  Future<void> setRate(double newRate) async {
    rate = newRate;
    await flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> setLanguage(String newLanguage) async {
    language = newLanguage;
    await flutterTts.setLanguage(language);
    notifyListeners();
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future<List<dynamic>?> getLanguages() async {
    return await flutterTts.getLanguages;
  }
}
