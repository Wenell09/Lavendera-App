import '../../domain/entities/outlet.dart';

class OutletModel {
  final String id;
  final String name;
  final String slug;
  final String phone;
  final String address;
  final bool isPublicOrderEnabled;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OutletModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.phone,
    required this.address,
    required this.isPublicOrderEnabled,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OutletModel.fromJson(Map<String, dynamic> json) {
    return OutletModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      isPublicOrderEnabled: json['is_public_order_enabled'] ?? false,
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Outlet toEntity() {
    return Outlet(
      id: id,
      name: name,
      slug: slug,
      phone: phone,
      address: address,
      isPublicOrderEnabled: isPublicOrderEnabled,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
