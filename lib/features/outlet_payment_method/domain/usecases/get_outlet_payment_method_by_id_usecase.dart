import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/domain/repositories/outlet_payment_method_repository.dart';

class GetOutletPaymentMethodByIdUsecase {
  final OutletPaymentMethodRepository repository;

  GetOutletPaymentMethodByIdUsecase(this.repository);

  Future<OutletPaymentMethod> call(
    String outletId,
    String paymentMethodId,
  ) async {
    return await repository.getOutletPaymentMethodById(outletId, paymentMethodId);
  }
}
