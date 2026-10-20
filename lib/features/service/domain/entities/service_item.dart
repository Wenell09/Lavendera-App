class ServiceCategorySummary {
  final String id;
  final String name;

  ServiceCategorySummary({
    required this.id,
    required this.name,
  });

  factory ServiceCategorySummary.fromJson(Map<String, dynamic> json) {
    return ServiceCategorySummary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class LaundryService {
  final String id;
  final ServiceCategorySummary category;
  final String name;
  final num price;
  final num minQuantity;
  final String unit; // 'kg', 'pcs', 'pair'
  final int durationDays;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LaundryService({
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
}
