import 'package:lavendera/features/outlet_payment_method/domain/repositories/outlet_payment_method_repository.dart';

class DeleteOutletPaymentMethodUsecase {
  final OutletPaymentMethodRepository repository;

  DeleteOutletPaymentMethodUsecase(this.repository);

  Future<void> call(String outletId, String paymentMethodId) async {
    return await repository.deleteOutletPaymentMethod(outletId, paymentMethodId);
  }
}
