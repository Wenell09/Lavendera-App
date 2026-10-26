import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUsecase {
  final OrderRepository repository;

  CreateOrderUsecase(this.repository);

  Future<OrderEntity> call(Map<String, dynamic> body) async {
    return await repository.createOrder(body);
  }
}
