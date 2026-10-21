import 'package:lavendera/core/models/pagination_model.dart';

import '../entities/outlet.dart';
import '../repositories/outlet_repository.dart';

class GetOutletsUsecase {
  final OutletRepository repository;
  GetOutletsUsecase(this.repository);
  Future<PaginatedResult<Outlet>> call({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getOutlets(
      search: search,
      page: page,
      limit: limit,
    );
  }
}
