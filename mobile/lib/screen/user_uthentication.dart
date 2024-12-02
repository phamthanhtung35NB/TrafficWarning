import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile/controller/user_authentication_state_controller.dart';
import 'package:mobile/screen/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/UserProvider.dart';
import 'liveness_detection.dart';

class UserAuthentication extends StatefulWidget {
  const UserAuthentication({super.key});

  @override
  _UserAuthenticationState createState() => _UserAuthenticationState();
}

class _UserAuthenticationState extends State<UserAuthentication> {
  final _formKey = GlobalKey<FormState>();
  final _controller = UserAuthenticationStateController();

  late TextEditingController _hoVaTenController;
  late TextEditingController _sdtController;
  late TextEditingController _namsinhController;
  String _linkFaceIdController = "";

  @override
  void initState() {
    super.initState();
    _hoVaTenController = TextEditingController();
    _sdtController = TextEditingController();
    _namsinhController = TextEditingController();
  }

  @override
  void dispose() {
    _hoVaTenController.dispose();
    _sdtController.dispose();
    _namsinhController.dispose();
    super.dispose();
  }
Future<void> _setUserData(
     String uid,
     String email,
     String hoVaTen,
     String linkFaceId,
     int namsinh,
     String sdt,
     bool authenticated,
  ) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentReference userRef = _firestore.collection('users').doc(uid);

    DocumentSnapshot userSnapshot = await userRef.get();

    // if (!userSnapshot.exists) {
      await userRef.set({
        'uid': uid,
        'email': email,
        'hoVaTen': hoVaTen,
        'linkFaceId': linkFaceId,
        'namsinh': namsinh,
        'sdt': sdt,
        'authenticated': authenticated,
      });
    // }

}
Future<void> _submit() async {
  var user = Provider.of<UserProvider>(context, listen: false);
  print("submit");
  print(_hoVaTenController.text);
  print(_sdtController.text);
  print(_namsinhController.text);
  print(_linkFaceIdController);

  // if (_formKey.currentState!.validate()) {
    try {
      print("trước cập nhật");
      _setUserData(
        user.uid,
        user.email,
         _hoVaTenController.text,
       _linkFaceIdController,
        int.parse(_namsinhController.text),
         _sdtController.text,
        true,
      );
      //chuyển tới màn hình login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      print("đã cập nhật");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Đăng nhập thất bị: $e')));
    }

}
  // Future<void> _submit() async {
  //   var user = Provider.of<UserProvider>(context, listen: false);
  //   print("submit");
  //   print(_hoVaTenController.text);
  //   print(_sdtController.text);
  //   print(_namsinhController.text);
  //   print(_linkFaceIdController);
  //
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       String result = await _controller.handleLoginAndUpdateInfo(
  //         email: user.email,
  //         password: 'password123',
  //         hoVaTen: _hoVaTenController.text,
  //         sdt: _sdtController.text,
  //         namsinh: _namsinhController.text,
  //         linkFaceId: _linkFaceIdController.toString(),
  //       );
  //
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text(result)));
  //     } catch (e) {
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $e')));
  //     }
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    bool _isVerified = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật thông tin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _hoVaTenController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sdtController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _namsinhController,
                decoration: const InputDecoration(labelText: 'Năm sinh'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập năm sinh';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final linkFaceId = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LivenessDetectionScreen()),
                  );

                  if (linkFaceId != null) {
                    setState(() {
                      _linkFaceIdController = linkFaceId.toString();
                      print("xác thực thành công" + linkFaceId);
                      _isVerified = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVerified ? Colors.grey : Colors.blue,
                ),
                child: Text(
                  _isVerified ? 'Đã xác thực' : 'Xác thực khuôn mặt',
                  style: TextStyle(
                    color: _isVerified ? Colors.white : Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Cập nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}