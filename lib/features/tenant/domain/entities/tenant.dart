class Tenant {
  final String id;
  final String name;
  final String slug;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tenant({
    required this.id,
    required this.name,
    required this.slug,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });
}
