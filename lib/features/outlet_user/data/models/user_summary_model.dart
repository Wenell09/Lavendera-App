import 'package:lavendera/features/outlet_user/domain/entities/user_summary.dart';

class UserSummaryModel extends UserSummary {
  UserSummaryModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.isActive,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserSummaryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_active': isActive,
    };
  }
}
