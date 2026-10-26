import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class InputCashPaymentUsecase {
  final OrderRepository repository;

  InputCashPaymentUsecase(this.repository);

  Future<OrderEntity> call(String orderId, num paidAmount) async {
    return await repository.inputCashPayment(orderId, paidAmount);
  }
}
