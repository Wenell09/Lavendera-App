import '../repositories/service_category_repository.dart';

class DeleteServiceCategoryUsecase {
  final ServiceCategoryRepository repository;

  DeleteServiceCategoryUsecase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteServiceCategory(id);
  }
}
