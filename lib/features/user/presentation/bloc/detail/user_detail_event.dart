part of 'user_detail_bloc.dart';

abstract class UserDetailEvent {}

class GetUserByIdRequest extends UserDetailEvent {
  final String id;
  GetUserByIdRequest({required this.id});
}
