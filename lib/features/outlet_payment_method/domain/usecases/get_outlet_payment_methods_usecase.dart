import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/domain/repositories/outlet_payment_method_repository.dart';

class GetOutletPaymentMethodsUsecase {
  final OutletPaymentMethodRepository repository;

  GetOutletPaymentMethodsUsecase(this.repository);

  Future<PaginatedResult<OutletPaymentMethod>> call(
    String outletId, {
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getOutletPaymentMethods(
      outletId,
      search: search,
      page: page,
      limit: limit,
    );
  }
}
