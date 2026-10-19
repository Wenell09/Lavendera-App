import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/discount/domain/entities/discount.dart';
import 'package:lavendera/features/discount/domain/repositories/discount_repository.dart';

class GetDiscountsUsecase {
  final DiscountRepository repository;

  GetDiscountsUsecase(this.repository);

  Future<PaginatedResult<Discount>> call({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getDiscounts(
      search: search,
      page: page,
      limit: limit,
    );
  }
}
