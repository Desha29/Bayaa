import 'package:hive/hive.dart';

import '../models/user_model.dart';

class UserDataSource {
  final Box _userBox = Hive.box<User>('userBox');
  void saveUser(User user) {
    try {
      if (_userBox.containsKey(user.username)) {
        throw Exception('User already exists');
      } else {
        _userBox.put(user.username, user);
      }
    } on Exception {
      rethrow;
    }
  }



  User? getUser(String username) {
    try {
      return _userBox.get(username);
    } on Exception {
      rethrow;
    }
  }

  List<User> getAllUsers() {
    try {
      print(_userBox.values.cast<User>().toList().first.password);
      print(_userBox.values.cast<User>().toList().first.username);
      return _userBox.values.cast<User>().toList();
    } on Exception {
      rethrow;
    }
  }

  void deleteUser(String username) {
    try {
      _userBox.delete(username);
    } on Exception {
      rethrow;
    }
  }
}
