import 'package:hive_flutter/hive_flutter.dart';

class CategoryDataSource {
  final Box _categoryBox = Hive.box('categoryBox');
  void saveCategory(String category) {
    try {
      _categoryBox.put(category, category);
    } on Exception {
      rethrow;
    }
  }

  List<String> getAllCategory() {
    try {
      return _categoryBox.keys.cast<String>().toList();
    } on Exception {
      rethrow;
    }
  }

  void deleteCategory(String category) {
    try {
      _categoryBox.delete(category);
    } on Exception {
      rethrow;
    }
  }
}
