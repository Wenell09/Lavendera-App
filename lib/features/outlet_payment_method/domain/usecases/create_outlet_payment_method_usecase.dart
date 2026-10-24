import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/domain/repositories/outlet_payment_method_repository.dart';

class CreateOutletPaymentMethodUsecase {
  final OutletPaymentMethodRepository repository;

  CreateOutletPaymentMethodUsecase(this.repository);

  Future<OutletPaymentMethod> call(
    String outletId,
    Map<String, dynamic> body,
  ) async {
    return await repository.createOutletPaymentMethod(outletId, body);
  }
}
