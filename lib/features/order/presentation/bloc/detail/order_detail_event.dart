part of 'order_detail_bloc.dart';

abstract class OrderDetailEvent {}

class GetOrderDetailRequest extends OrderDetailEvent {
  final String id;

  GetOrderDetailRequest({required this.id});
}
