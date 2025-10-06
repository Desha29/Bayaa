import 'package:hive_flutter/adapters.dart';

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
}

class UserTypeAdapter extends TypeAdapter<UserType> {
  @override
  final int typeId = 0;

  @override
  UserType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserType.manager;
      case 1:
        return UserType.cashier;
      default:
        return UserType.manager;
    }
  }

  @override
  void write(BinaryWriter writer, UserType obj) {
    switch (obj) {
      case UserType.manager:
        writer.writeByte(0);
        break;
      case UserType.cashier:
        writer.writeByte(1);
        break;
    }
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      username: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      userType: fields[3] as UserType,
      password: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(5) // عدد الفيلدز = 5
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.userType)
      ..writeByte(4)
      ..write(obj.password);
  }
}
