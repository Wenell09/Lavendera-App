class Discount {
  final String id;
  final String name;
  final String type; // 'percentage' or 'fixed'
  final num value;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Discount({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
