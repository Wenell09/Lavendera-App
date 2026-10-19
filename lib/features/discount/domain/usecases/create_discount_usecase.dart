import 'package:lavendera/features/discount/domain/entities/discount.dart';
import 'package:lavendera/features/discount/domain/repositories/discount_repository.dart';

class CreateDiscountUsecase {
  final DiscountRepository repository;

  CreateDiscountUsecase(this.repository);

  Future<Discount> call(Map<String, dynamic> body) async {
    return await repository.createDiscount(body);
  }
}
