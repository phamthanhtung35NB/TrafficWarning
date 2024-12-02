import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/UserProvider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Hồ Sơ Cá Nhân',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar với tick xác thực
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
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
                      backgroundImage: NetworkImage(user.linkFaceId),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          user.authenticated
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: user.authenticated
                              ? Colors.green
                              : Colors.red,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tên người dùng
              Text(
                user.hoVaTen,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              // Thông tin chi tiết
              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                content: user.email,
              ),
              const SizedBox(height: 15),
              _buildInfoCard(
                icon: Icons.phone_outlined,
                title: 'Số Điện Thoại',
                content: user.sdt,
              ),
              const SizedBox(height: 15),
              _buildInfoCard(
                icon: Icons.cake_outlined,
                title: 'Năm Sinh',
                content: user.namsinh.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm xây dựng thẻ thông tin
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            )
          ]
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 5),
              Text(
                content,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}