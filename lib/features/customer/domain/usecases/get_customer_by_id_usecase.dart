import 'package:lavendera/features/customer/domain/entities/customer.dart';
import 'package:lavendera/features/customer/domain/repositories/customer_repository.dart';

class GetCustomerByIdUsecase {
  final CustomerRepository repository;

  GetCustomerByIdUsecase(this.repository);

  Future<Customer> call(String id) async {
    return await repository.getCustomerById(id);
  }
}
