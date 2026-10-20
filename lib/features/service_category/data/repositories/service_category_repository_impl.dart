import '../../domain/entities/service_category.dart';
import '../../domain/repositories/service_category_repository.dart';
import '../datasources/service_category_remote_data_source.dart';

class ServiceCategoryRepositoryImpl implements ServiceCategoryRepository {
  final ServiceCategoryRemoteDataSource remoteDataSource;

  ServiceCategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ServiceCategory>> getServiceCategories() async {
    final models = await remoteDataSource.getServiceCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ServiceCategory> getServiceCategoryById(String id) async {
    final model = await remoteDataSource.getServiceCategoryById(id);
    return model.toEntity();
  }

  @override
  Future<ServiceCategory> createServiceCategory(Map<String, dynamic> body) async {
    final model = await remoteDataSource.createServiceCategory(body);
    return model.toEntity();
  }

  @override
  Future<ServiceCategory> updateServiceCategory(
    String id,
    Map<String, dynamic> body,
  ) async {
    final model = await remoteDataSource.updateServiceCategory(id, body);
    return model.toEntity();
  }

  @override
  Future<void> deleteServiceCategory(String id) async {
    await remoteDataSource.deleteServiceCategory(id);
  }
}
