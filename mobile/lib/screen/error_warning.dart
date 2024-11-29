import 'package:flutter/material.dart';
import 'package:mobile/screen/dual_camera_screen.dart';
import 'package:mobile/screen/camera_screen.dart';
import 'package:mobile/screen/liveness_detection.dart';
class ErrorWarning extends StatefulWidget {
  const ErrorWarning({super.key});

  @override
  _ErrorWarningState createState() => _ErrorWarningState();
}

class _ErrorWarningState extends State<ErrorWarning> {
  String _selectedIncident = 'cháy';
  bool _showOtherField = false;
  TextEditingController _otherIncidentController = TextEditingController();

  @override
  void dispose() {
    _otherIncidentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Báo cáo sự cố'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Báo cáo:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                //TODO: mở máy ảnh chụp ảnh
                print('Chụp ảnh');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LivenessDetectionScreen()),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text("Chụp ảnh"),
                  Icon(Icons.camera_alt),
                ],
              ),
            ),
            const Text('Chọn loại sự cố:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedIncident,
                items: <String>['cháy', 'lụt', 'tắc đường', 'sạt lở', 'khác']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    //căn giữa 2 text
                    alignment: Alignment.center,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedIncident = newValue!;
                    _showOtherField = _selectedIncident == 'khác';
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            if (_showOtherField)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nhập loại sự cố khác:', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  TextField(
                    controller: _otherIncidentController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Loại sự cố khác',
                    ),
                  ),
                ],
              ),
            SizedBox(height: 10),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nội dung báo cáo',
              ),
            ),
            //check box
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // căn giữa 2 text
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Use mainAxisAlignment instead of alignment
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (bool? value) {},
                      ),
                      const Text('Gửi báo cáo'),
                    ],
                  ),
                ),

              ],
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Gửi báo cáo'),
            ),
          ],
        ),
      ),
    );
  }
}
