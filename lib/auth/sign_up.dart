import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/user.dart';
import '../service/database_service.dart';
import 'sign_in.dart'; // Nhập DatabaseService

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String name = '';
  String password = '';

  // Tạo một instance của DatabaseService
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Ký'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tên'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Xử lý đăng ký ở đây
                    try {
                      // Đăng ký người dùng với Firebase Auth
                      UserCredential userCredential = await _databaseService
                          .createUserWithEmailAndPassword(email, password);
                      if (userCredential.user != null) {
                        // Tạo một instance của AppUser
                        AppUser newUser = AppUser(
                          id: userCredential
                              .user!.uid, // Lấy UID từ Firebase Auth
                          email: email,
                          name: name,
                          password: password, // Có thể không cần lưu mật khẩu
                        );
                        // Gọi hàm createUser từ DatabaseService
                        await _databaseService.createUser(newUser);
                        print('Đăng ký thành công: Email: $email, Tên: $name');

                        // Hiển thị dialog thông báo thành công
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Thành công'),
                              content: const Text('Đăng ký thành công!'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Đóng dialog
                                    Navigator.of(context)
                                        .pop(); // Quay về trang chính
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } catch (e) {
                      print('Lỗi khi đăng ký: $e');
                    }
                  }
                },
                child: const Text('Đăng Ký'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Chuyển hướng đến trang đăng nhập
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LoginPage()), // Thay LoginPage bằng trang đăng nhập của bạn
                  );
                },
                child: const Text('Đã có tài khoản? Đăng nhập ngay!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
