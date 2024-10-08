class AppUser {
  String id; // Thêm thuộc tính id
  String email;
  String name;
  String password;
  String profileImageUrl; // Thêm thuộc tính này

  AppUser({
    required this.id, // Thêm tham số id
    required this.email,
    required this.name,
    required this.password,
    this.profileImageUrl = '', // Khởi tạo với giá trị mặc định
  });

  // Phương thức để chuyển đổi từ Map sang AppUser
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id, // Gán document ID
      email: data['email'],
      name: data['name'],
      password: data['password'],
      profileImageUrl:
          data['profileImageUrl'] ?? '', // Lấy profileImageUrl từ Map
    );
  }

  // Phương thức để chuyển đổi từ AppUser sang Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'profileImageUrl': profileImageUrl, // Thêm profileImageUrl vào Map
    };
  }
}
