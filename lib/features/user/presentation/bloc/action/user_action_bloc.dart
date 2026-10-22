import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/user/domain/usecases/create_user_usecase.dart';
import 'package:lavendera/features/user/domain/usecases/delete_user_usecase.dart';
import 'package:lavendera/features/user/domain/usecases/update_user_usecase.dart';

part 'user_action_event.dart';
part 'user_action_state.dart';

class UserActionBloc extends Bloc<UserActionEvent, UserActionState> {
  final CreateUserUsecase _createUserUsecase;
  final UpdateUserUsecase _updateUserUsecase;
  final DeleteUserUsecase _deleteUserUsecase;

  UserActionBloc({
    required this._createUserUsecase,
    required this._updateUserUsecase,
    required this._deleteUserUsecase,
  }) : super(UserActionInitial()) {
    on<CreateUserActionRequest>((event, emit) async {
      emit(UserActionLoading());
      try {
        await _createUserUsecase.call(event.body);
        emit(UserActionSuccess(message: 'berhasil menambah pengguna'));
      } on ApiException catch (e) {
        emit(UserActionError(message: e.message));
      } catch (e) {
        emit(UserActionError(message: 'Gagal menambah pengguna'));
      }
    });

    on<UpdateUserActionRequest>((event, emit) async {
      emit(UserActionLoading());
      try {
        await _updateUserUsecase.call(event.id, event.body);
        emit(UserActionSuccess(message: 'berhasil memperbarui pengguna'));
      } on ApiException catch (e) {
        emit(UserActionError(message: e.message));
      } catch (e) {
        emit(UserActionError(message: 'Gagal memperbarui pengguna'));
      }
    });

    on<DeleteUserActionRequest>((event, emit) async {
      emit(UserActionLoading());
      try {
        await _deleteUserUsecase.call(event.id);
        emit(UserActionSuccess(message: 'berhasil menghapus pengguna'));
      } on ApiException catch (e) {
        emit(UserActionError(message: e.message));
      } catch (e) {
        emit(UserActionError(message: 'Gagal menghapus pengguna'));
      }
    });
  }
}
