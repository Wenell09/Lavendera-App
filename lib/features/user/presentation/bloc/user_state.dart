part of 'user_bloc.dart';

abstract class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserPaginationLoading extends UserState {
  final List<User> users;
  final int currentPage;
  final bool hasMorePages;

  UserPaginationLoading({
    required this.users,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class UserLoaded extends UserState {
  final List<User> users;
  final int currentPage;
  final bool hasMorePages;

  UserLoaded({
    required this.users,
    required this.currentPage,
    required this.hasMorePages,
  });
}

final class UserError extends UserState {
  final String message;
  final List<User>? cachedUsers;

  UserError({required this.message, this.cachedUsers});
}
