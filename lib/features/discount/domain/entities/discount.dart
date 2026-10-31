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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Discount && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
