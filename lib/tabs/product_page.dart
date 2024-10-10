import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/product.dart'; // Nhập lớp Product
import '../service/database_service.dart'; // Nhập DatabaseService
import '../model/user.dart'; // Nhập lớp User

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key); // Thêm tham số key

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Product> _products = [];
  List<Product> _filteredProducts = []; // Danh sách sản phẩm đã lọc
  AppUser? currentUser; // Biến để lưu thông tin người dùng hiện tại
  String _searchQuery = ''; // Biến để lưu truy vấn tìm kiếm

  @override
  void initState() {
    super.initState();
    _loadProducts(); // Tải danh sách sản phẩm khi khởi tạo
    _loadCurrentUser(); // Tải thông tin người dùng hiện tại
  }

  void _loadCurrentUser() async {
    // Giả sử bạn có một phương thức để lấy thông tin người dùng hiện tại
    currentUser = await _databaseService
        .getCurrentUser(); // Cập nhật phương thức này theo cách bạn lấy người dùng
  }

  void _loadProducts() async {
    _products = await _databaseService.readProducts();
    _filteredProducts =
        _products; // Khởi tạo danh sách đã lọc bằng danh sách gốc
    setState(() {});
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts =
          _products; // Nếu không có truy vấn, hiển thị tất cả sản phẩm
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList(); // Lọc sản phẩm theo tên
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddProductDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thêm TextField cho tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm sản phẩm',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterProducts(_searchQuery); // Gọi hàm lọc sản phẩm
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  leading: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          height: 100, // Chiều cao của ảnh
                          width: 100, // Chiều rộng của ảnh
                          fit: BoxFit.contain, // Cách hiển thị ảnh
                        )
                      : const SizedBox(
                          height: 100,
                          width: 100,
                          child: Icon(Icons.image,
                              size:
                                  100), // Hiển thị biểu tượng nếu không có ảnh
                        ),
                  title: Text(product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Giá: ${product.price.toStringAsFixed(0)} VND'), // Định dạng giá tiền
                      FutureBuilder<String>(
                        future: _databaseService.getUserNameById(
                            product.createdBy), // Truy vấn tên người tạo
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('Đang tải tên người tạo...');
                          } else if (snapshot.hasError) {
                            return const Text('Lỗi khi tải tên người tạo');
                          } else {
                            return Text(
                                'Người tạo: ${snapshot.data}'); // Hiển thị tên người tạo
                          }
                        },
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditProductDialog(
                              context, product); // Sửa sản phẩm
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteProduct(product); // Xóa sản phẩm
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    String imageUrl = ''; // Biến để lưu URL hình ảnh
    final ImagePicker _picker = ImagePicker(); // Khởi tạo ImagePicker

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm Sản Phẩm'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Giá sản phẩm'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
                ),
                // Nút để chọn ảnh
                ElevatedButton(
                  onPressed: () async {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // Tải ảnh lên Firebase Storage
                      String fileName = image.name;
                      File file = File(image.path);
                      try {
                        // Tải ảnh lên Firebase Storage
                        TaskSnapshot snapshot = await FirebaseStorage.instance
                            .ref('products/$fileName')
                            .putFile(file);
                        // Lấy URL của ảnh
                        imageUrl = await snapshot.ref.getDownloadURL();
                        print('URL hình ảnh: $imageUrl');
                      } catch (e) {
                        print('Lỗi khi tải ảnh lên: $e');
                      }
                    }
                  },
                  child: const Text('Chọn Ảnh'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Xử lý thông tin sản phẩm ở đây
                String name = nameController.text;
                double price = double.tryParse(priceController.text) ?? 0.0;
                String type = typeController.text;
                String createdBy = currentUser?.id ??
                    ''; // Lấy document ID của người dùng hiện tại

                // Tạo một instance của Product
                Product newProduct = Product(
                    id: '',
                    name: name,
                    price: price,
                    type: type,
                    createdBy: createdBy,
                    imageUrl: imageUrl); // Sử dụng URL hình ảnh

                // Lưu sản phẩm vào Firestore
                _databaseService.createProduct(newProduct).then((_) {
                  _loadProducts(); // Tải lại danh sách sản phẩm
                });

                // Đóng dialog
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final TextEditingController nameController =
        TextEditingController(text: product.name);
    final TextEditingController priceController =
        TextEditingController(text: product.price.toString());
    final TextEditingController typeController =
        TextEditingController(text: product.type);
    String imageUrl = product.imageUrl; // Lưu URL hình ảnh hiện tại
    final ImagePicker _picker = ImagePicker(); // Khởi tạo ImagePicker

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sửa Sản Phẩm'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Giá sản phẩm'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Loại sản phẩm'),
                ),
                // Nút để chọn ảnh
                ElevatedButton(
                  onPressed: () async {
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // Tải ảnh lên Firebase Storage
                      String fileName = image.name;
                      File file = File(image.path);
                      try {
                        // Tải ảnh lên Firebase Storage
                        TaskSnapshot snapshot = await FirebaseStorage.instance
                            .ref('products/$fileName')
                            .putFile(file);
                        // Lấy URL của ảnh
                        imageUrl = await snapshot.ref.getDownloadURL();
                        print('URL hình ảnh: $imageUrl');
                      } catch (e) {
                        print('Lỗi khi tải ảnh lên: $e');
                      }
                    }
                  },
                  child: const Text('Chọn Ảnh'),
                ),
                // Hiển thị URL hình ảnh hiện tại
                if (imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(
                      imageUrl,
                      height: 100, // Chiều cao của ảnh
                      fit: BoxFit.cover, // Cách hiển thị ảnh
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Cập nhật thông tin sản phẩm
                String name = nameController.text;
                double price = double.tryParse(priceController.text) ?? 0.0;
                String type = typeController.text;
                String createdBy = product.createdBy; // Giữ nguyên createdBy

                // Tạo một instance của Product
                Product updatedProduct = Product(
                    id: product.id,
                    name: name,
                    price: price,
                    type: type,
                    createdBy: createdBy,
                    imageUrl: imageUrl); // Sử dụng URL hình ảnh

                // Cập nhật sản phẩm trong Firestore
                _databaseService
                    .updateProduct(product.id, updatedProduct)
                    .then((_) {
                  _loadProducts(); // Tải lại danh sách sản phẩm
                });

                // Đóng dialog
                Navigator.of(context).pop();
              },
              child: const Text('Cập nhật'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(Product product) {
    _databaseService.deleteProduct(product.id).then((_) {
      _loadProducts(); // Tải lại danh sách sản phẩm
    });
  }
}
