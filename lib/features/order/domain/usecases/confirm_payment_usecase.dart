import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class ConfirmPaymentUsecase {
  final OrderRepository repository;

  ConfirmPaymentUsecase(this.repository);

  Future<OrderEntity> call(String orderId, String paymentId) async {
    return await repository.confirmPayment(orderId, paymentId);
  }
}
