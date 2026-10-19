import 'package:lavendera/features/discount/domain/entities/discount.dart';
import 'package:lavendera/features/discount/domain/repositories/discount_repository.dart';

class UpdateDiscountUsecase {
  final DiscountRepository repository;

  UpdateDiscountUsecase(this.repository);

  Future<Discount> call(String id, Map<String, dynamic> body) async {
    return await repository.updateDiscount(id, body);
  }
}
