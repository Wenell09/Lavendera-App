class Outlet {
  final String id;
  final String name;
  final String slug;
  final String phone;
  final String address;
  final bool isPublicOrderEnabled;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Outlet({
    required this.id,
    required this.name,
    required this.slug,
    required this.phone,
    required this.address,
    required this.isPublicOrderEnabled,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
