import 'package:firebase_database/firebase_database.dart';
import 'package:mobile/config.dart';

class HomeController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>> fetchDevices() async {
    DatabaseEvent event = await _database.child('devices').once();
    if (event.snapshot.exists) {
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    } else {
      return {};
    }
  }
}