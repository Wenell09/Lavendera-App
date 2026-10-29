class Profile {
  final String id;
  final String tenantId;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });
}
