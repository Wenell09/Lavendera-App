import '../entities/tenant.dart';
import '../repositories/tenant_repository.dart';

class UpdateTenantUsecase {
  final TenantRepository repository;

  UpdateTenantUsecase(this.repository);

  Future<Tenant> call(String id, Map<String, dynamic> body) async {
    return await repository.updateTenant(id, body);
  }
}
