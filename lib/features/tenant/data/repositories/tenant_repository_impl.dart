import '../../domain/entities/tenant.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/tenant_remote_data_source.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantRemoteDataSource remoteDataSource;

  TenantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Tenant> getTenant(String id) async {
    final model = await remoteDataSource.getTenant(id);
    return model.toEntity();
  }

  @override
  Future<Tenant> updateTenant(String id, Map<String, dynamic> body) async {
    final model = await remoteDataSource.updateTenant(id, body);
    return model.toEntity();
  }
}
