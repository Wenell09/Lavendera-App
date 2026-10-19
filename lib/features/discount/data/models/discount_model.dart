import '../../domain/entities/discount.dart';

class DiscountModel {
  final String id;
  final String name;
  final String type;
  final num value;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiscountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'percentage',
      value: json['value'] ?? 0,
      isActive: json['is_active'] ?? false,
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
      'type': type,
      'value': value,
      'is_active': isActive,
    };
  }

  Discount toEntity() {
    return Discount(
      id: id,
      name: name,
      type: type,
      value: value,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
