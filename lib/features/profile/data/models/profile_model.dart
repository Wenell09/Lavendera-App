import '../../domain/entities/profile.dart';

class ProfileModel {
  final String id;
  final String tenantId;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      tenantId: json['tenant_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Profile toEntity() {
    return Profile(
      id: id,
      tenantId : tenantId,
      name: name,
      email: email,
      role: role,
      createdAt: createdAt,
    );
  }
}
