import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mid_term/model/user.dart';
import '../service/database_service.dart'; // Nhập DatabaseService
import '../tabs/bottom_navigation_bar.dart'; // Nhập BottomNavigationBar

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  // Tạo một instance của DatabaseService
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Nhập'),
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
                    try {
                      // Đăng nhập bằng Firebase Authentication
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // Chuyển đổi User thành AppUser
                      AppUser appUser = await _databaseService
                          .convertUser(userCredential.user!);

                      print('Đăng nhập thành công: Email: ${appUser.email}');
                      // Chuyển hướng đến BottomNavigationBar
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomBottomNavigationBar(user: appUser),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    } catch (e) {
                      print('Lỗi khi đăng nhập: $e');
                    }
                  }
                },
                child: const Text('Đăng Nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
