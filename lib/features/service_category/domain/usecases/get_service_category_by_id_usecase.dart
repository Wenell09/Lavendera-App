import '../entities/service_category.dart';
import '../repositories/service_category_repository.dart';

class GetServiceCategoryByIdUsecase {
  final ServiceCategoryRepository repository;

  GetServiceCategoryByIdUsecase(this.repository);

  Future<ServiceCategory> call(String id) async {
    return await repository.getServiceCategoryById(id);
  }
}
