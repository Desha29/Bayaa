enum UserType { manager, cashier }

class User {
  String username;
  String name;
  String phone;
  UserType userType;
  String password;
  User({
    required this.username,
    required this.name,
    required this.phone,
    required this.userType,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'phone': phone,
      'userType': userType.index,
      'password': password,
    };
  }
}
