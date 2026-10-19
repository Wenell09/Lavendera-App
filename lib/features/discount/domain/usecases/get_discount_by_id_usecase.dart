import 'package:lavendera/features/discount/domain/entities/discount.dart';
import 'package:lavendera/features/discount/domain/repositories/discount_repository.dart';

class GetDiscountByIdUsecase {
  final DiscountRepository repository;

  GetDiscountByIdUsecase(this.repository);

  Future<Discount> call(String id) async {
    return await repository.getDiscountById(id);
  }
}
