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

  // final _controller = UserAuthenticationStateController();

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

// Hàm hiển thị dialog xác nhận thông tin
  Future<bool?> _showConfirmationDialog(BuildContext context) {
    bool _isConfirmed = false; // State to track checkbox
    bool _isConfirmed2 = false;
    bool _isConfirmed3 = false;
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // Increase dialog width and adjust shape
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              // Make the dialog take up more screen space
              insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),

              title: Text(
                'Xác Nhận Thông Tin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),

              content: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
                  maxWidth: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                  maxHeight: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Bạn có chắc chắn với các thông tin sau?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(_linkFaceIdController),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildInfoRow('Họ và Tên:', _hoVaTenController.text),
                      SizedBox(height: 10),
                      _buildInfoRow('Số Điện Thoại:', _sdtController.text),
                      SizedBox(height: 10),
                      _buildInfoRow('Năm Sinh:', _namsinhController.text),
                      SizedBox(height: 20),
                      SizedBox(height: 15),
                      Row(
                        children: [Checkbox(
                          value: _isConfirmed,
                          onChanged: (bool? value) {
                            setState(() {
                              _isConfirmed = value ?? false;
                            });
                          },
                        ),
                          Expanded(
                            child: Text(
                              "BẠN LÀ NGƯỜI VỪA XÁC THỰC KHUÔN MẶT",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [Checkbox(
                          value: _isConfirmed2,
                          onChanged: (bool? value) {
                            setState(() {
                              _isConfirmed2 = value ?? false;
                            });
                          },
                        ),
                          Expanded(
                            child: Text(
                              "Tuân thủ các quy định, chính sách bảo mật của ứng dụng.",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [Checkbox(
                          value: _isConfirmed3,
                          onChanged: (bool? value) {
                            setState(() {
                              _isConfirmed3 = value ?? false;
                            });
                          },
                        ),
                          Expanded(
                            child: Text(
                              "Cam kết cung cấp thông tin chính xác.",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                        ],
                      ),
                      Text(
                        'LƯU Ý: Thông tin này sẽ KHÔNG THỂ THAY ĐỔI sau này!',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                          ),
                          child: Text(
                            'Hủy',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isConfirmed ? Colors.blue : Colors.grey,
                          ),
                          child: Text(
                            'Xác Nhận',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _isConfirmed&&_isConfirmed2&&_isConfirmed3
                              ? () {
                            Navigator.of(context).pop(true);
                          }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Helper method to create consistent info rows
  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black87, fontSize: 16),
        children: [
          TextSpan(
              text: label,
              style: TextStyle(fontWeight: FontWeight.bold)
          ),
          TextSpan(text: ' $value'),
        ],
      ),
    );
  }

// Hàm submit được cập nhật
  Future<void> _submit() async {
    var user = Provider.of<UserProvider>(context, listen: false);

    // Kiểm tra xác thực khuôn mặt
    if (_linkFaceIdController == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Vui lòng xác thực khuôn mặt')));
      return;
    }

    // Hiển thị dialog xác nhận
    bool? confirmed = await _showConfirmationDialog(context);

    // Nếu người dùng xác nhận
    if (confirmed == true) {
      try {
        _setUserData(
          user.uid,
          user.email,
          _hoVaTenController.text,
          _linkFaceIdController,
          int.parse(_namsinhController.text),
          _sdtController.text,
          true,
        );

        // Chuyển tới màn hình login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $e')));
      }
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
