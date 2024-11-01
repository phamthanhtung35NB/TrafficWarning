import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/screen/login_screen.dart';
import 'package:mobile/screen/home_screen.dart';

import 'config.dart'; // Nhập file cấu hình

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Config.apiKey,
        authDomain: Config.authDomain,
        databaseURL: Config.databaseURL,
        projectId: Config.projectId,
        storageBucket: Config.storageBucket,
        messagingSenderId: Config.messagingSenderId,
        appId: Config.appId,
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ULISync',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/login_screen': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}