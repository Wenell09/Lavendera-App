part of 'user_detail_bloc.dart';

abstract class UserDetailState {}

class UserDetailInitial extends UserDetailState {}

class UserDetailLoading extends UserDetailState {}

class UserDetailLoaded extends UserDetailState {
  final User user;
  UserDetailLoaded({required this.user});
}

class UserDetailError extends UserDetailState {
  final String message;
  UserDetailError({required this.message});
}
