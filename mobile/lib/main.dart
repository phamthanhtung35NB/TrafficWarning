import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile/screen/login_screen.dart';
import 'package:mobile/screen/home_screen.dart';
import 'package:mobile/screen/register_screen.dart';
import 'package:mobile/screen/settings.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/UserProvider.dart'; // Import UserProvider
import 'package:mobile/screen/user_uthentication.dart';
import 'config.dart';
import 'model/tts_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()), // Bao bọc bằng UserProvider
        ChangeNotifierProvider(create: (context) => TTSProvider()),
      ],
      child: MaterialApp(
        title: 'Traffic Warning',
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/home_screen': (context) => const HomeScreen(),
          '/login_screen': (context) => const LoginScreen(),
          '/register_screen': (context) => const RegisterScreen(),
          '/user_uthentication': (context) => const UserAuthentication(),
          '/settings': (context) => SettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:mobile/provider/user_provider.dart';
// import 'package:mobile/screen/home_screen.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => UserProvider()),
//       ],
//       child: MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: const HomeScreen(), // Hoặc màn hình đăng nhập của bạn
//       ),
//     );
//   }
// }
