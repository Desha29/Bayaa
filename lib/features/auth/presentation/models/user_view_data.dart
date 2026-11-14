enum PreviewRole { manager, cashier }

class UserViewData {
  String username;
  String name;
  String phone;
  PreviewRole userType;
  String password;
  String? imagePath;
  UserViewData({
    required this.username,
    required this.name,
    required this.phone,
    required this.userType,
    required this.password,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'phone': phone,
      'userType': userType.index,
      'password': password,
      'imagePath': imagePath,
    };
  }
}
