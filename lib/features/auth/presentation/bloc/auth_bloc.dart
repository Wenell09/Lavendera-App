import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
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
        add(
          LoginRequest(
            email: event.data['email'],
            password: event.data['password'],
          ),
        );
      } on ApiException catch (e) {
        emit(AuthError(message: e.message));
      } catch (e) {
        emit(AuthError(message: 'Terjadi kesalahan yang tidak terduga.'));
      }
    });

    on<LoginRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _loginUsecase.call(event.email, event.password);
        emit(AuthLoaded(userId: result['id'], token: result['token']));
      } on ApiException catch (e) {
        emit(AuthError(message: e.message));
      } catch (e) {
        emit(AuthError(message: 'Terjadi kesalahan yang tidak terduga.'));
      }
    });

    on<LoadDataRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await _loadDataUsecase.call();
        final userId = result['id'];
        final token = result['token'];
        if (userId == null || token == null) {
          emit(Unauthenticated());
          return;
        }
        emit(AuthLoaded(userId: userId, token: token));
      } on ApiException catch (e) {
        emit(AuthError(message: e.message));
      } catch (e) {
        emit(AuthError(message: 'Terjadi kesalahan yang tidak terduga.'));
      }
    });

    on<LogoutRequest>((event, emit) async {
      emit(AuthLoading());
      try {
        await _logoutUsecase.call();
        emit(Unauthenticated());
      } on ApiException catch (e) {
        emit(AuthError(message: e.message));
      } catch (e) {
        emit(AuthError(message: 'Terjadi kesalahan yang tidak terduga.'));
      }
    });
  }
}
