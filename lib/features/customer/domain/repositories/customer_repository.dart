import 'package:lavendera/core/models/pagination_model.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Customer> createCustomer(Map<String, dynamic> body);
  Future<PaginatedResult<Customer>> getCustomers({String? search, int page = 1, int limit = 10});
  Future<Customer> getCustomerById(String id);
  Future<Customer> updateCustomer(String id, Map<String, dynamic> body);
  Future<void> deleteCustomer(String id);
}
