// lib/core/data/models/base_model.dart

/// Base interface for all data models
abstract class BaseModel {
  String get id;
  Map<String, dynamic> toJson();
  Map<String, dynamic> toSQLite();
}
