import 'package:lavendera/core/models/pagination_model.dart';

import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUsecase {
  final OrderRepository repository;

  GetOrdersUsecase(this.repository);

  Future<PaginatedResult<OrderEntity>> call({
    String? search,
    String? status,
    String? outletId,
    String? customerId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getOrders(
      search: search,
      status: status,
      outletId: outletId,
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }
}
