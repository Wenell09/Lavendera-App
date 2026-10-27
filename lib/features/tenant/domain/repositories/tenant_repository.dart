import '../entities/tenant.dart';

abstract class TenantRepository {
  Future<Tenant> getTenant(String id);
  Future<Tenant> updateTenant(String id, Map<String, dynamic> body);
}
