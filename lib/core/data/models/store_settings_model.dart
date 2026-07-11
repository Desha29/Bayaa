// lib/core/data/models/store_settings_model.dart

import 'dart:io';
import 'dart:typed_data';

class StoreSettingsModel {
  static const String SINGLETON_ID = 'store_settings_singleton';

  final String id;
  final String storeName;
  final String? storeAddress;
  final String? storePhone;
  final String? storeEmail;
  final String? logoPath;
  final double taxRate;
  final String currency;
  final String invoicePrefix;
  final int lastInvoiceNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Uint8List? _logoBytes;

  StoreSettingsModel({
    String? id,
    required this.storeName,
    this.storeAddress,
    this.storePhone,
    this.storeEmail,
    this.logoPath,
    this.taxRate = 0.0,
    this.currency = 'EGP',
    this.invoicePrefix = 'INV',
    this.lastInvoiceNumber = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? SINGLETON_ID,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Future<Uint8List?> getLogoBytes() async {
    if (_logoBytes != null) return _logoBytes;

    if (logoPath != null && logoPath!.isNotEmpty) {
      final file = File(logoPath!);
      if (await file.exists()) {
        _logoBytes = await file.readAsBytes();
        return _logoBytes;
      }
    }
    return null;
  }

  String generateNextInvoiceNumber() {
    final nextNumber = lastInvoiceNumber + 1;
    return '$invoicePrefix-${nextNumber.toString().padLeft(6, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': storeName,
      'store_address': storeAddress,
      'store_phone': storePhone,
      'store_email': storeEmail,
      'logo_path': logoPath,
      'tax_rate': taxRate,
      'currency': currency,
      'invoice_prefix': invoicePrefix,
      'last_invoice_number': lastInvoiceNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSQLite() => toJson();

  factory StoreSettingsModel.fromSQLite(Map<String, dynamic> map) {
    return StoreSettingsModel(
      id: map['id'] as String,
      storeName: map['store_name'] as String,
      storeAddress: map['store_address'] as String?,
      storePhone: map['store_phone'] as String?,
      storeEmail: map['store_email'] as String?,
      logoPath: map['logo_path'] as String?,
      taxRate: (map['tax_rate'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'EGP',
      invoicePrefix: map['invoice_prefix'] as String? ?? 'INV',
      lastInvoiceNumber: (map['last_invoice_number'] as int?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  factory StoreSettingsModel.defaultSettings() {
    return StoreSettingsModel(
      storeName: 'Bayaa Store',
      storeAddress: 'Address not set',
      storePhone: '0000000000',
      currency: 'EGP',
      invoicePrefix: 'INV',
    );
  }

  StoreSettingsModel copyWith({
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? storeEmail,
    String? logoPath,
    double? taxRate,
    String? currency,
    String? invoicePrefix,
    int? lastInvoiceNumber,
  }) {
    return StoreSettingsModel(
      id: id,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      storeEmail: storeEmail ?? this.storeEmail,
      logoPath: logoPath ?? this.logoPath,
      taxRate: taxRate ?? this.taxRate,
      currency: currency ?? this.currency,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      lastInvoiceNumber: lastInvoiceNumber ?? this.lastInvoiceNumber,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
