import 'package:lavendera/core/models/pagination_model.dart';
import '../entities/service_item.dart';
import '../repositories/service_repository.dart';

class GetServicesUsecase {
  final ServiceRepository repository;

  GetServicesUsecase(this.repository);

  Future<PaginatedResult<LaundryService>> call({
    String? search,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getServices(
      search: search,
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
  }
}
