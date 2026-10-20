import '../entities/service_category.dart';
import '../repositories/service_category_repository.dart';

class CreateServiceCategoryUsecase {
  final ServiceCategoryRepository repository;

  CreateServiceCategoryUsecase(this.repository);

  Future<ServiceCategory> call(Map<String, dynamic> body) async {
    return await repository.createServiceCategory(body);
  }
}
