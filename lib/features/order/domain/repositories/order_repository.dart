import 'package:lavendera/core/models/pagination_model.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> createOrder(Map<String, dynamic> body);

  Future<PaginatedResult<OrderEntity>> getOrders({
    String? search,
    String? status,
    String? outletId,
    String? customerId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  });

  Future<OrderEntity> getOrderById(String id);

  Future<OrderEntity> updateOrderStatus(String id, String status);

  Future<OrderEntity> cancelOrder(String id);

  Future<OrderEntity> confirmPayment(String orderId, String paymentId);

  Future<OrderEntity> inputCashPayment(String orderId, num paidAmount);
}
