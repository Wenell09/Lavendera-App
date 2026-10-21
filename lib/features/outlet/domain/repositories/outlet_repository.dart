import 'package:lavendera/core/models/pagination_model.dart';
import '../entities/outlet.dart';

abstract class OutletRepository {
  Future<Outlet> createOutlet(Map<String, dynamic> body);
  Future<PaginatedResult<Outlet>> getOutlets({
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Outlet> getOutletById(String id);
  Future<Outlet> updateOutlet(String id, Map<String, dynamic> body);
  Future<void> deleteOutlet(String id);
}
