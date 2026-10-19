import 'package:lavendera/core/models/pagination_model.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Customer> createCustomer(Map<String, dynamic> body) async {
    final model = await remoteDataSource.createCustomer(body);
    return model.toEntity();
  }

  @override
  Future<PaginatedResult<Customer>> getCustomers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await remoteDataSource.getCustomers(
      search: search,
      page: page,
      limit: limit,
    );
    return PaginatedResult<Customer>(
      data: result.data.map((model) => model.toEntity()).toList(),
      pagination: result.pagination,
    );
  }

  @override
  Future<Customer> getCustomerById(String id) async {
    final model = await remoteDataSource.getCustomerById(id);
    return model.toEntity();
  }

  @override
  Future<Customer> updateCustomer(String id, Map<String, dynamic> body) async {
    final model = await remoteDataSource.updateCustomer(id, body);
    return model.toEntity();
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await remoteDataSource.deleteCustomer(id);
  }
}
