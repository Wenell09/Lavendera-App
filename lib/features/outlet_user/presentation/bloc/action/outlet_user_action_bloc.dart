import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/outlet_user/domain/usecases/assign_user_to_outlet_usecase.dart';
import 'package:lavendera/features/outlet_user/domain/usecases/unassign_user_from_outlet_usecase.dart';

part 'outlet_user_action_event.dart';
part 'outlet_user_action_state.dart';

class OutletUserActionBloc
    extends Bloc<OutletUserActionEvent, OutletUserActionState> {
  final AssignUserToOutletUsecase _assignUserToOutletUsecase;
  final UnassignUserFromOutletUsecase _unassignUserFromOutletUsecase;

  OutletUserActionBloc({
    required this._assignUserToOutletUsecase,
    required this._unassignUserFromOutletUsecase,
  }) : super(OutletUserActionInitial()) {
    on<AssignUserToOutletActionRequest>((event, emit) async {
      emit(OutletUserActionLoading());
      try {
        await _assignUserToOutletUsecase.call(event.outletId, event.userId);
        emit(
          OutletUserActionSuccess(
            message: 'User berhasil ditambahkan ke outlet',
          ),
        );
      } on ApiException catch (e) {
        emit(OutletUserActionError(message: e.message));
      } catch (e) {
        emit(
          OutletUserActionError(message: 'Gagal menambahkan user ke outlet'),
        );
      }
    });

    on<UnassignUserFromOutletActionRequest>((event, emit) async {
      emit(OutletUserActionLoading());
      try {
        await _unassignUserFromOutletUsecase.call(event.outletId, event.userId);
        emit(
          OutletUserActionSuccess(message: 'User berhasil dihapus dari outlet'),
        );
      } on ApiException catch (e) {
        emit(OutletUserActionError(message: e.message));
      } on Exception {
        emit(
          OutletUserActionError(message: 'Gagal menghapus user dari outlet'),
        );
      }
    });
  }
}
