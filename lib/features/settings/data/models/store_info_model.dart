// store_info_model.dart
import 'package:hive_flutter/adapters.dart';

class StoreInfo {
  String name;
  String address;
  String phone;
  String email;
  String vat;
  String? logoPath;

  StoreInfo({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.vat,
    this.logoPath,
  });

  Map<String, String> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'vat': vat,
      'logoPath': logoPath ?? '',
    };
  }

  factory StoreInfo.fromMap(Map<dynamic, dynamic> map) {
    return StoreInfo(
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      vat: map['vat']?.toString() ?? '',
      logoPath: map['logoPath']?.toString(),
    );
  }
}


class StoreInfoAdapter extends TypeAdapter<StoreInfo> {
  @override
  final int typeId = 2;

  @override
  StoreInfo read(BinaryReader reader) {
    return StoreInfo(
      name: reader.readString(),
      address: reader.readString(),
      phone: reader.readString(),
      email: reader.readString(),
      vat: reader.readString(),
      logoPath: reader.readString(), 
    );
  }

  @override
  void write(BinaryWriter writer, StoreInfo obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.address);
    writer.writeString(obj.phone);
    writer.writeString(obj.email);
    writer.writeString(obj.vat);
    writer.writeString(obj.logoPath ?? ''); 
  }
}
