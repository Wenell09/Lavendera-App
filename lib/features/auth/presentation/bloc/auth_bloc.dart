import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:lavendera/features/auth/domain/usecases/load_data_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/login_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/logout_usecase.dart';
import 'package:lavendera/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final LogoutUsecase _logoutUsecase;
  final LoadDataUsecase _loadDataUsecase;
  AuthBloc({
    required this._loginUsecase,
    required this._registerUsecase,
    required this._loadDataUsecase,
    required this._logoutUsecase,
  }) : super(AuthInitial()) {
    on<RegisterRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        await _registerUsecase.call(event.data);
        add(LoginRequest(email: event.data['email'], password: event.data['password']));
      } catch (e) {
        emit(AuthError());
      }
    });
    on<LoginRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _loginUsecase.call(event.email, event.password);
        emit(AuthLoaded(userId: result["id"], token: result["token"]));
      } catch (e) {
        emit(AuthError());
      }
    });
    on<LoadDataRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _loadDataUsecase.call();
        final userId = result["id"];
        final token = result["token"];
        debugPrint("token:$token, userid:$userId");
        if (userId == null || token == null) {
          emit(Unauthenticated());
          return;
        }
        emit(AuthLoaded(userId: userId, token: token));
      } catch (e) {
        emit(AuthError());
      }
    });
    on<LogoutRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        await _logoutUsecase.call();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError());
      }
    });
  }
}
