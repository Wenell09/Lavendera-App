import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String tenantId;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      tenantId: json['tenant_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  User toEntity() {
    return User(
      id: id,
      tenantId: tenantId,
      name: name,
      email: email,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
