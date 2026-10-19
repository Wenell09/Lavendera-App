class Customer {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });
}
