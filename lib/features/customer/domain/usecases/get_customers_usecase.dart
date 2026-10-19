import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/repositories/customer_repository.dart';

class GetCustomersUsecase {
  final CustomerRepository repository;

  GetCustomersUsecase(this.repository);

  Future<PaginatedResult<Customer>> call({String? search, int page = 1, int limit = 10}) async {
    return await repository.getCustomers(search: search, page: page, limit: limit);
  }
}
