import 'package:lavendera/features/customer/domain/repositories/customer_repository.dart';

class DeleteCustomerUsecase {
  final CustomerRepository repository;

  DeleteCustomerUsecase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteCustomer(id);
  }
}
