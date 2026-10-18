part of 'auth_bloc.dart';

class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthLoaded extends AuthState {
  final String userId;
  final String token;
  AuthLoaded({required this.userId, required this.token});
}

final class Authenticated extends AuthState {}

final class Unauthenticated extends AuthState {}

final class AuthError extends AuthState {}
