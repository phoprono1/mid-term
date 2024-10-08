import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Nhập Firebase Auth
import '../model/product.dart';
import '../model/user.dart'; // Nhập lớp Product

class DatabaseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Khởi tạo Firebase Auth

  Future<AppUser> convertUser(User user) async {
    // Giả sử bạn có một phương thức để lấy thông tin người dùng từ Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return AppUser(
      id: user.uid,
      email: user.email!,
      name: userDoc['name'],
      password: '', // Giả sử bạn có trường 'name' trong Firestore
      // Thêm các thuộc tính khác nếu cần
      profileImageUrl:
          userDoc['profileImageUrl'] ?? '', // Lấy URL hình ảnh đại diện
    );
  }

  // Hàm tạo người dùng với Firebase Auth
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Hàm tạo người dùng trong Firestore
  Future<void> createUser(AppUser user) async {
    try {
      await _fire
          .collection("users")
          .doc(user.id)
          .set(user.toMap()); // Sử dụng set để tạo hoặc cập nhật
      log('Người dùng đã được tạo thành công với ID: ${user.id}');
    } catch (e) {
      log('Lỗi khi tạo người dùng: ${e.toString()}');
    }
  }

  // Hàm đọc người dùng
  Future<List<AppUser>> readUsers() async {
    // Thay đổi User thành AppUser
    try {
      QuerySnapshot snapshot = await _fire.collection("users").get();
      return snapshot.docs
          .map((doc) => AppUser.fromMap(
              doc.id, doc.data() as Map<String, dynamic>)) // Truyền document ID
          .toList();
    } catch (e) {
      log('Lỗi khi đọc người dùng: ${e.toString()}');
      return [];
    }
  }

  // Hàm lấy người dùng theo ID
  Future<AppUser?> getUserById(String userId) async {
    // Thay đổi User thành AppUser
    try {
      DocumentSnapshot doc = await _fire.collection("users").doc(userId).get();
      if (doc.exists) {
        return AppUser.fromMap(
            doc.id, doc.data() as Map<String, dynamic>); // Trả về người dùng
      }
      return null; // Không tìm thấy người dùng
    } catch (e) {
      log('Lỗi khi lấy người dùng: ${e.toString()}');
      return null;
    }
  }

  Future<String> getUserNameById(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _fire.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['name']; // Giả sử trường tên là 'name'
      } else {
        return 'Người dùng không tồn tại';
      }
    } catch (e) {
      print('Lỗi khi lấy tên người dùng: $e');
      return 'Lỗi';
    }
  }

  // Hàm lấy người dùng hiện tại
  Future<AppUser?> getCurrentUser() async {
    // Thay đổi User thành AppUser
    try {
      User? firebaseUser =
          _auth.currentUser; // Lấy người dùng hiện tại từ Firebase Auth
      if (firebaseUser != null) {
        // Nếu người dùng hiện tại không null, lấy thông tin từ Firestore
        DocumentSnapshot doc =
            await _fire.collection("users").doc(firebaseUser.uid).get();
        if (doc.exists) {
          return AppUser.fromMap(
              doc.id, doc.data() as Map<String, dynamic>); // Trả về người dùng
        }
      }
      return null; // Không có người dùng hiện tại
    } catch (e) {
      log('Lỗi khi lấy người dùng hiện tại: ${e.toString()}');
      return null;
    }
  }

  // Hàm cập nhật người dùng
  Future<void> updateUser(String userId, AppUser user) async {
    try {
      await _fire.collection("users").doc(userId).update(user.toMap());
      log('Người dùng đã được cập nhật thành công');
    } catch (e) {
      log('Lỗi khi cập nhật người dùng: ${e.toString()}');
    }
  }

  // Hàm xóa người dùng
  Future<void> deleteUser(String userId) async {
    try {
      await _fire.collection("users").doc(userId).delete();
      log('Người dùng đã được xóa thành công');
    } catch (e) {
      log('Lỗi khi xóa người dùng: ${e.toString()}');
    }
  }

  // Hàm đăng nhập người dùng
  Future<AppUser?> loginUser(String email, String password) async {
    // Thay đổi User thành AppUser
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Lấy thông tin người dùng từ Firestore
      return await getUserById(
          userCredential.user!.uid); // Trả về thông tin người dùng với ID
    } catch (e) {
      log('Lỗi khi đăng nhập: ${e.toString()}');
      return null;
    }
  }

  // Hàm tạo sản phẩm
  Future<void> createProduct(Product product) async {
    try {
      await _fire.collection("products").add(product.toMap());
      log('Sản phẩm đã được tạo thành công');
    } catch (e) {
      log('Lỗi khi tạo sản phẩm: ${e.toString()}');
    }
  }

  // Hàm đọc sản phẩm
  Future<List<Product>> readProducts() async {
    try {
      QuerySnapshot snapshot = await _fire.collection("products").get();
      return snapshot.docs
          .map((doc) => Product.fromMap(
              doc.id, doc.data() as Map<String, dynamic>)) // Truyền document ID
          .toList();
    } catch (e) {
      log('Lỗi khi đọc sản phẩm: ${e.toString()}');
      return [];
    }
  }

  // Hàm cập nhật sản phẩm
  Future<void> updateProduct(String productId, Product product) async {
    try {
      await _fire.collection("products").doc(productId).update(product.toMap());
      log('Sản phẩm đã được cập nhật thành công');
    } catch (e) {
      log('Lỗi khi cập nhật sản phẩm: ${e.toString()}');
    }
  }

  // Hàm xóa sản phẩm
  Future<void> deleteProduct(String productId) async {
    try {
      await _fire.collection("products").doc(productId).delete();
      log('Sản phẩm đã được xóa thành công');
    } catch (e) {
      log('Lỗi khi xóa sản phẩm: ${e.toString()}');
    }
  }
}
