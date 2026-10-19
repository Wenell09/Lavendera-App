import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/repositories/customer_repository.dart';

class CreateCustomerUsecase {
  final CustomerRepository repository;

  CreateCustomerUsecase(this.repository);

  Future<Customer> call(Map<String, dynamic> body) async {
    return await repository.createCustomer(body);
  }
}
