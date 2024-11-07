import 'package:firebase_database/firebase_database.dart';

class Firebasedb {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get all devices once
  Future<Map<String, dynamic>> fetchDevices() async {
    DatabaseEvent event = await _database.child('devices').once();
    if (event.snapshot.exists) {
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    } else {
      return {};
    }
  }

  // Listen to device changes in real-time
void listenToDeviceChanges(void Function(Map<String, dynamic>) onData) {
  _database.child('devices').onValue.listen((event) {
    if (event.snapshot.exists) {
      onData(Map<String, dynamic>.from(event.snapshot.value as Map));
    } else {
      onData({});
    }
  });
}
}