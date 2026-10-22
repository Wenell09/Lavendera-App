import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/outlet/domain/usecases/create_outlet_usecase.dart';
import 'package:lavendera/features/outlet/domain/usecases/delete_outlet_usecase.dart';
import 'package:lavendera/features/outlet/domain/usecases/update_outlet_usecase.dart';

part 'outlet_action_event.dart';
part 'outlet_action_state.dart';

class OutletActionBloc extends Bloc<OutletActionEvent, OutletActionState> {
  final CreateOutletUsecase _createOutletUsecase;
  final UpdateOutletUsecase _updateOutletUsecase;
  final DeleteOutletUsecase _deleteOutletUsecase;

  OutletActionBloc({
    required this._createOutletUsecase,
    required this._updateOutletUsecase,
    required this._deleteOutletUsecase,
  })  : super(OutletActionInitial()) {
    on<CreateOutletActionRequest>((event, emit) async {
      emit(OutletActionLoading());
      try {
        await _createOutletUsecase.call(event.body);
        emit(OutletActionSuccess(message: 'Berhasil menambah outlet'));
      } on ApiException catch (e) {
        emit(OutletActionError(message: e.message));
      } catch (e) {
        emit(OutletActionError(message: 'Gagal menambah outlet'));
      }
    });

    on<UpdateOutletActionRequest>((event, emit) async {
      emit(OutletActionLoading());
      try {
        await _updateOutletUsecase.call(event.id, event.body);
        emit(OutletActionSuccess(message: 'Berhasil memperbarui outlet'));
      } on ApiException catch (e) {
        emit(OutletActionError(message: e.message));
      } catch (e) {
        emit(OutletActionError(message: 'Gagal memperbarui outlet'));
      }
    });

    on<DeleteOutletActionRequest>((event, emit) async {
      emit(OutletActionLoading());
      try {
        await _deleteOutletUsecase.call(event.id);
        emit(OutletActionSuccess(message: 'Berhasil menghapus outlet'));
      } on ApiException catch (e) {
        emit(OutletActionError(message: e.message));
      } catch (e) {
        emit(OutletActionError(message: 'Gagal menghapus outlet'));
      }
    });
  }
}
