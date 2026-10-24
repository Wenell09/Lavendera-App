import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';

class OutletPaymentMethodModel {
  final String id;
  final String type;
  final String providerName;
  final String? accountNumber;
  final String accountName;
  final String? qrImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OutletPaymentMethodModel({
    required this.id,
    required this.type,
    required this.providerName,
    this.accountNumber,
    required this.accountName,
    this.qrImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OutletPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return OutletPaymentMethodModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      providerName: json['provider_name'] ?? '',
      accountNumber: json['account_number'],
      accountName: json['account_name'] ?? '',
      qrImageUrl: json['qr_image_url'],
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  OutletPaymentMethod toEntity() {
    return OutletPaymentMethod(
      id: id,
      type: type,
      providerName: providerName,
      accountNumber: accountNumber,
      accountName: accountName,
      qrImageUrl: qrImageUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
