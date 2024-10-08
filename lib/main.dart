import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mid_term/auth/sign_in.dart';
import 'package:mid_term/firebase_options.dart';
import 'package:mid_term/tabs/bottom_navigation_bar.dart';
import 'package:mid_term/service/database_service.dart'; // Nhập DatabaseService
import 'package:mid_term/model/user.dart'; // Nhập AppUser

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // Người dùng đã đăng nhập
              User? user = snapshot.data;
              return FutureBuilder<AppUser>(
                future: DatabaseService()
                    .convertUser(user!), // Chuyển đổi User thành AppUser
                builder: (context, appUserSnapshot) {
                  if (appUserSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (appUserSnapshot.hasError) {
                    return const Center(
                        child: Text('Lỗi khi tải thông tin người dùng'));
                  } else {
                    return CustomBottomNavigationBar(
                        user: appUserSnapshot
                            .data!); // Truyền thông tin người dùng
                  }
                },
              );
            } else {
              // Người dùng chưa đăng nhập
              return LoginPage();
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
