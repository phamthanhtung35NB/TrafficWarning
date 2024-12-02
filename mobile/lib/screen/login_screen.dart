import 'package:flutter/material.dart';
import 'package:mobile/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final LoginController _loginController = LoginController();
  String? _verificationId;

  Future<void> _login() async {
    String? result = await _loginController.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (result != null) {
      print("UID: $result");
      if (result.length == 28) {
        Navigator.pushNamed(context, '/home_screen', arguments: result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful. UID: $result')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    String? result = await _loginController.loginWithGoogle();

    if (result != null) {
      print("UID: $result");
      if (result.length == 28) {
        Navigator.pushNamed(context, '/home_screen', arguments: result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful. UID: $result')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    final TextEditingController emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Enter your email',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String? result = await _loginController.resetPassword(emailController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result ?? 'An error occurred')),
                );
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'test@gmail.com';
    _passwordController.text = '123456';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
      ),
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children:[ Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                width: 150.0,
                height: 150.0,
                child: Image(
                  image: AssetImage('assets/images/logo.png'),
                ),
              ),
              const SizedBox(height: 50.0),
              Container(
                width: 300.0,
                height: 50.0,
                child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                width: 300.0,
                height: 50.0,
                child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Đăng nhập'),
              ),
              const SizedBox(height: 16.0),
              // hiện text hoặc đăng nhập bằng Google, gạch chân dưới chữ
              const Text('Hoặc đăng nhập bằng', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ElevatedButton.icon(
                onPressed: _loginWithGoogle,
                icon: SvgPicture.network(
                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                  height: 24.0,
                  width: 24.0,
                ),
                label: const Text(
                  'Đăng nhập bằng Google',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Nền trắng
                  foregroundColor: Colors.black, // Chữ màu đen
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.grey.shade300), // Viền mỏng
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
              ),

              const SizedBox(height: 16.0),


              const SizedBox(height: 10.0),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _resetPassword,
                child: const Text('Bạn quên mật khẩu?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register_screen');
                },
                child: const Text('Đăng ký ngay?'),
              ),
            ],
          ),
        ),
        ]
      ),



    );
  }
}