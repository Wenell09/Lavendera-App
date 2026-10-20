import 'package:lavendera/core/models/pagination_model.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_data_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaginatedResult<LaundryService>> getServices({
    String? search,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await remoteDataSource.getServices(
      search: search,
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
    return PaginatedResult<LaundryService>(
      data: result.data.map((model) => model.toEntity()).toList(),
      pagination: result.pagination,
    );
  }

  @override
  Future<LaundryService> getServiceById(String id) async {
    final model = await remoteDataSource.getServiceById(id);
    return model.toEntity();
  }

  @override
  Future<LaundryService> createService(Map<String, dynamic> body) async {
    final model = await remoteDataSource.createService(body);
    return model.toEntity();
  }

  @override
  Future<LaundryService> updateService(
    String id,
    Map<String, dynamic> body,
  ) async {
    final model = await remoteDataSource.updateService(id, body);
    return model.toEntity();
  }

  @override
  Future<void> deleteService(String id) async {
    await remoteDataSource.deleteService(id);
  }
}
