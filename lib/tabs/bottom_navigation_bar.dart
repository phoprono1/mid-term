import 'package:flutter/material.dart';
import '../model/user.dart'; // Nhập lớp User
import 'product_page.dart';
import 'user_info_page.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final AppUser user; // Thêm biến để nhận thông tin người dùng

  CustomBottomNavigationBar({required this.user}); // Constructor

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0; // Chỉ số tab hiện tại

  // Danh sách các widget cho từng tab
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách các widget với thông tin người dùng
    _pages.add(ProductPage());
    _pages.add(UserInfoPage(user: widget.user)); // Truyền thông tin người dùng
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cập nhật chỉ số tab hiện tại
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Admin'),
      ),
      body:
          _pages[_selectedIndex], // Hiển thị widget tương ứng với tab hiện tại
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User Info',
          ),
        ],
        currentIndex: _selectedIndex, // Chỉ số tab hiện tại
        onTap: _onItemTapped, // Hàm xử lý khi nhấn tab
      ),
    );
  }
}
