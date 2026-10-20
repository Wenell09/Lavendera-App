import '../entities/service_category.dart';
import '../repositories/service_category_repository.dart';

class GetServiceCategoriesUsecase {
  final ServiceCategoryRepository repository;

  GetServiceCategoriesUsecase(this.repository);

  Future<List<ServiceCategory>> call() async {
    return await repository.getServiceCategories();
  }
}
