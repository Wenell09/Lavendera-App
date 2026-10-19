import 'package:lavendera/features/discount/domain/repositories/discount_repository.dart';

class DeleteDiscountUsecase {
  final DiscountRepository repository;

  DeleteDiscountUsecase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteDiscount(id);
  }
}
