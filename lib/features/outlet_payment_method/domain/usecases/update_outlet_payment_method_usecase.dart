import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/domain/repositories/outlet_payment_method_repository.dart';

class UpdateOutletPaymentMethodUsecase {
  final OutletPaymentMethodRepository repository;

  UpdateOutletPaymentMethodUsecase(this.repository);

  Future<OutletPaymentMethod> call(
    String outletId,
    String paymentMethodId,
    Map<String, dynamic> body,
  ) async {
    return await repository.updateOutletPaymentMethod(
      outletId,
      paymentMethodId,
      body,
    );
  }
}
