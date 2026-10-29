import 'package:lavendera/features/service/domain/entities/service_item.dart';

class OrderCartItem {
  final LaundryService service;
  num quantity;

  OrderCartItem({required this.service, required this.quantity});

  num get subtotal => service.price * quantity;
}
