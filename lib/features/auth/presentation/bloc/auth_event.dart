part of 'auth_bloc.dart';

class AuthEvent {}

class LoginRequest extends AuthEvent {
  final String email, password;
  LoginRequest({required this.email, required this.password});
}

class RegisterRequest extends AuthEvent {
  Map<String, dynamic> data;
  RegisterRequest({required this.data});
}

class LoadDataRequest extends AuthEvent {}

class LogoutRequest extends AuthEvent {}
