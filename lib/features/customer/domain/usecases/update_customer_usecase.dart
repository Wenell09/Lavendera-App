import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/repositories/customer_repository.dart';

class UpdateCustomerUsecase {
  final CustomerRepository repository;

  UpdateCustomerUsecase(this.repository);

  Future<Customer> call(String id, Map<String, dynamic> body) async {
    return await repository.updateCustomer(id, body);
  }
}
