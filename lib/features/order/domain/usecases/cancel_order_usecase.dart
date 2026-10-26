import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CancelOrderUsecase {
  final OrderRepository repository;

  CancelOrderUsecase(this.repository);

  Future<OrderEntity> call(String id) async{
    return await repository.cancelOrder(id);
  }
}
