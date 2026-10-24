import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';

abstract class OutletPaymentMethodRepository {
  Future<OutletPaymentMethod> createOutletPaymentMethod(
    String outletId,
    Map<String, dynamic> body,
  );

  Future<PaginatedResult<OutletPaymentMethod>> getOutletPaymentMethods(
    String outletId, {
    String? search,
    int page = 1,
    int limit = 10,
  });

  Future<OutletPaymentMethod> getOutletPaymentMethodById(
    String outletId,
    String paymentMethodId,
  );

  Future<OutletPaymentMethod> updateOutletPaymentMethod(
    String outletId,
    String paymentMethodId,
    Map<String, dynamic> body,
  );

  Future<void> deleteOutletPaymentMethod(
    String outletId,
    String paymentMethodId,
  );
}
