import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Nhập Firebase Auth
import '../auth/sign_in.dart';
import '../model/user.dart'; // Nhập lớp User

class UserInfoPage extends StatelessWidget {
  final AppUser user; // Thêm biến để nhận thông tin người dùng

  UserInfoPage({required this.user}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Cá Nhân'),
      ),
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hiển thị hình ảnh đại diện nếu có
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.profileImageUrl.isNotEmpty
                      ? NetworkImage(user
                          .profileImageUrl) // Giả sử bạn có trường profileImageUrl
                      : const AssetImage('assets/images/default_avatar.jpg')
                          as ImageProvider, // Hình ảnh mặc định
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Tên: ${user.name}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Email: ${user.email}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Xử lý đăng xuất
                    await FirebaseAuth.instance.signOut();
                    // Chuyển hướng về trang đăng nhập hoặc trang chính
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) =>
                              LoginPage()), // Thay LoginPage bằng trang đăng nhập của bạn
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Đăng Xuất'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
