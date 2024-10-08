class Product {
  String id; // Thêm thuộc tính id
  String name;
  double price;
  String type;
  String createdBy; // Thêm thuộc tính createdBy
  String imageUrl; // Thêm thuộc tính imageUrl

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.createdBy, // Thêm tham số createdBy
    required this.imageUrl, // Thêm tham số imageUrl
  });

  // Phương thức để chuyển đổi từ Map sang Product
  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id, // Gán document ID
      name: data['name'],
      price: data['price'],
      type: data['type'],
      createdBy: data['createdBy'], // Gán createdBy
      imageUrl: data['imageUrl'], // Gán imageUrl
    );
  }

  // Phương thức để chuyển đổi từ Product sang Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'type': type,
      'createdBy': createdBy, // Thêm createdBy vào Map
      'imageUrl': imageUrl, // Thêm imageUrl vào Map
    };
  }
}
