import '../../domain/entities/service_item.dart';

class ServiceModel {
  final String id;
  final ServiceCategorySummary category;
  final String name;
  final num price;
  final num minQuantity;
  final String unit;
  final int durationDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    required this.minQuantity,
    required this.unit,
    required this.durationDays,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      category: json['category'] != null
          ? ServiceCategorySummary.fromJson(json['category'])
          : ServiceCategorySummary(id: '', name: '-'),
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      minQuantity: json['min_quantity'] ?? 1,
      unit: json['unit'] ?? 'kg',
      durationDays: json['duration_days'] ?? 1,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.toJson(),
      'name': name,
      'price': price,
      'min_quantity': minQuantity,
      'unit': unit,
      'duration_days': durationDays,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LaundryService toEntity() {
    return LaundryService(
      id: id,
      category: category,
      name: name,
      price: price,
      minQuantity: minQuantity,
      unit: unit,
      durationDays: durationDays,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
