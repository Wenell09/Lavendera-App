import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusUsecase {
  final OrderRepository repository;

  UpdateOrderStatusUsecase(this.repository);

  Future<OrderEntity> call(String id, String status) async {
    return await repository.updateOrderStatus(id, status);
  }
}
