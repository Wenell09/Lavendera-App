import 'package:lavendera/core/models/pagination_model.dart';
import '../../domain/entities/outlet.dart';
import '../../domain/repositories/outlet_repository.dart';
import '../datasources/outlet_remote_data_source.dart';

class OutletRepositoryImpl implements OutletRepository {
  final OutletRemoteDataSource remoteDataSource;

  OutletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Outlet> createOutlet(Map<String, dynamic> body) async {
    final model = await remoteDataSource.createOutlet(body);
    return model.toEntity();
  }

  @override
  Future<PaginatedResult<Outlet>> getOutlets({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await remoteDataSource.getOutlets(
      search: search,
      page: page,
      limit: limit,
    );
    return PaginatedResult<Outlet>(
      data: result.data.map((m) => m.toEntity()).toList(),
      pagination: result.pagination,
    );
  }

  @override
  Future<Outlet> getOutletById(String id) async {
    final model = await remoteDataSource.getOutletById(id);
    return model.toEntity();
  }

  @override
  Future<Outlet> updateOutlet(String id, Map<String, dynamic> body) async {
    final model = await remoteDataSource.updateOutlet(id, body);
    return model.toEntity();
  }

  @override
  Future<void> deleteOutlet(String id) async {
    await remoteDataSource.deleteOutlet(id);
  }
}
