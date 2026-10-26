import 'package:lavendera/core/models/pagination_model.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrderEntity> createOrder(Map<String, dynamic> body) async {
    final model = await remoteDataSource.createOrder(body);
    return model.toEntity();
  }

  @override
  Future<PaginatedResult<OrderEntity>> getOrders({
    String? search,
    String? status,
    String? outletId,
    String? customerId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    final paginatedResult = await remoteDataSource.getOrders(
      search: search,
      status: status,
      outletId: outletId,
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
    return PaginatedResult<OrderEntity>(
      data: paginatedResult.data.map((m) => m.toEntity()).toList(),
      pagination: paginatedResult.pagination,
    );
  }

  @override
  Future<OrderEntity> getOrderById(String id) async {
    final model = await remoteDataSource.getOrderById(id);
    return model.toEntity();
  }

  @override
  Future<OrderEntity> updateOrderStatus(String id, String status) async {
    final model = await remoteDataSource.updateOrderStatus(id, status);
    return model.toEntity();
  }

  @override
  Future<OrderEntity> cancelOrder(String id) async {
    final model = await remoteDataSource.cancelOrder(id);
    return model.toEntity();
  }

  @override
  Future<OrderEntity> confirmPayment(String orderId, String paymentId) async {
    final model = await remoteDataSource.confirmPayment(orderId, paymentId);
    return model.toEntity();
  }

  @override
  Future<OrderEntity> inputCashPayment(String orderId, num paidAmount) async {
    final model = await remoteDataSource.inputCashPayment(orderId, paidAmount);
    return model.toEntity();
  }
}
