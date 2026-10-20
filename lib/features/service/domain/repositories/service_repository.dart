import 'package:lavendera/core/models/pagination_model.dart';
import '../entities/service_item.dart';

abstract class ServiceRepository {
  Future<PaginatedResult<LaundryService>> getServices({
    String? search,
    String? categoryId,
    int page = 1,
    int limit = 10,
  });

  Future<LaundryService> getServiceById(String id);

  Future<LaundryService> createService(Map<String, dynamic> body);

  Future<LaundryService> updateService(String id, Map<String, dynamic> body);

  Future<void> deleteService(String id);
}
