// store_info_model.dart

class StoreViewData {
  String name;
  String address;
  String phone;
  String email;
  String vat;
  String? logoPath;

  StoreViewData({
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

  factory StoreViewData.fromMap(Map<dynamic, dynamic> map) {
    return StoreViewData(
      name: map['name']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      vat: map['vat']?.toString() ?? '',
      logoPath: map['logoPath']?.toString(),
    );
  }
}
