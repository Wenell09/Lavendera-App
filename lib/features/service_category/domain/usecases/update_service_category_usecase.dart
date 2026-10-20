import '../entities/service_category.dart';
import '../repositories/service_category_repository.dart';

class UpdateServiceCategoryUsecase {
  final ServiceCategoryRepository repository;

  UpdateServiceCategoryUsecase(this.repository);

  Future<ServiceCategory> call(String id, Map<String, dynamic> body) async {
    return await repository.updateServiceCategory(id, body);
  }
}
