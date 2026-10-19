import 'package:lavendera/core/models/pagination_model.dart';
import '../entities/discount.dart';

abstract class DiscountRepository {
  Future<Discount> createDiscount(Map<String, dynamic> body);
  Future<PaginatedResult<Discount>> getDiscounts({
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<Discount> getDiscountById(String id);
  Future<Discount> updateDiscount(String id, Map<String, dynamic> body);
  Future<void> deleteDiscount(String id);
}
