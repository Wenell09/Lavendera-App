import '../entities/service_category.dart';

abstract class ServiceCategoryRepository {
  Future<List<ServiceCategory>> getServiceCategories();
  Future<ServiceCategory> getServiceCategoryById(String id);
  Future<ServiceCategory> createServiceCategory(Map<String, dynamic> body);
  Future<ServiceCategory> updateServiceCategory(String id, Map<String, dynamic> body);
  Future<void> deleteServiceCategory(String id);
}
