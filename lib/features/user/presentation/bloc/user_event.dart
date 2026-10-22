part of 'user_bloc.dart';

abstract class UserEvent {}

class GetUsersRequest extends UserEvent {
  final String? search;
  final int page;
  final int limit;

  GetUsersRequest({this.search, this.page = 1, this.limit = 10});
}
