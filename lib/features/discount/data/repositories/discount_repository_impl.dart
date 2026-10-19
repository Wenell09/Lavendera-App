import 'package:lavendera/core/models/pagination_model.dart';
import '../../domain/entities/discount.dart';
import '../../domain/repositories/discount_repository.dart';
import '../datasources/discount_remote_data_source.dart';

class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountRemoteDataSource remoteDataSource;

  DiscountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Discount> createDiscount(Map<String, dynamic> body) async {
    final model = await remoteDataSource.createDiscount(body);
    return model.toEntity();
  }

  @override
  Future<PaginatedResult<Discount>> getDiscounts({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await remoteDataSource.getDiscounts(
      search: search,
      page: page,
      limit: limit,
    );
    return PaginatedResult<Discount>(
      data: result.data.map((model) => model.toEntity()).toList(),
      pagination: result.pagination,
    );
  }

  @override
  Future<Discount> getDiscountById(String id) async {
    final model = await remoteDataSource.getDiscountById(id);
    return model.toEntity();
  }

  @override
  Future<Discount> updateDiscount(String id, Map<String, dynamic> body) async {
    final model = await remoteDataSource.updateDiscount(id, body);
    return model.toEntity();
  }

  @override
  Future<void> deleteDiscount(String id) async {
    await remoteDataSource.deleteDiscount(id);
  }
}
