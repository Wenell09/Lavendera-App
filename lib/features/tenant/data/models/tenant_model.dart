import '../../domain/entities/tenant.dart';

class TenantModel {
  final String id;
  final String name;
  final String slug;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  TenantModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Tenant toEntity() {
    return Tenant(
      id: id,
      name: name,
      slug: slug,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
