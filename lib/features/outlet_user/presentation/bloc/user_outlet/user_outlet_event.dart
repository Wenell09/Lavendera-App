part of 'user_outlet_bloc.dart';

class UserOutletEvent {}

class GetUserOutletRequest extends UserOutletEvent {
  final String userId;
  GetUserOutletRequest({required this.userId});
}
