import '../entities/tenant.dart';
import '../repositories/tenant_repository.dart';

class GetTenantUsecase {
  final TenantRepository repository;

  GetTenantUsecase(this.repository);

  Future<Tenant> call(String id) async {
    return await repository.getTenant(id);
  }
}
