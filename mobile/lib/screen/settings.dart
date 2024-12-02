import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/tts_provider.dart'; // Đường dẫn cần được chỉnh sửa theo cấu trúc dự án của bạn

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _supportedLanguages = [];

  @override
  void initState() {
    super.initState();
    _loadSupportedLanguages();
  }

  Future<void> _loadSupportedLanguages() async {
    final ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    final languages = await ttsProvider.getLanguages();

    if (languages != null && languages.isNotEmpty) {
      setState(() {
        _supportedLanguages = languages.cast<String>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt Text-to-Speech'),
      ),
      body: Consumer<TTSProvider>(
        builder: (context, ttsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Điều chỉnh Âm lượng
              _buildSliderSetting(
                title: 'Âm lượng',
                value: ttsProvider.volume,
                min: 0.0,
                max: 1.0,
                onChanged: (value) => ttsProvider.setVolume(value),
              ),

              // Điều chỉnh Pitch
              _buildSliderSetting(
                title: 'Độ cao giọng',
                value: ttsProvider.pitch,
                min: 0.5,
                max: 2.0,
                onChanged: (value) => ttsProvider.setPitch(value),
              ),

              // Điều chỉnh Tốc độ đọc
              _buildSliderSetting(
                title: 'Tốc độ đọc',
                value: ttsProvider.rate,
                min: 0.1,
                max: 1.0,
                onChanged: (value) => ttsProvider.setRate(value),
              ),

              // Chọn Ngôn ngữ
              _buildLanguageDropdown(ttsProvider),

              // Nút Test TTS
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () => ttsProvider.speak('Đây là bản test âm thanh'),
                  child: const Text('Thử giọng đọc'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget tạo slider cài đặt
  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 10,
          label: value.toStringAsFixed(2),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Widget dropdown chọn ngôn ngữ
  Widget _buildLanguageDropdown(TTSProvider ttsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngôn ngữ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: ttsProvider.language,
          items: _supportedLanguages.map((String language) {
            return DropdownMenuItem<String>(
              value: language,
              child: Text(language),
            );
          }).toList(),
          onChanged: (String? newLanguage) {
            if (newLanguage != null) {
              ttsProvider.setLanguage(newLanguage);
            }
          },
        ),
      ],
    );
  }
}
