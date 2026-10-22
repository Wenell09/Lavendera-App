import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/service/domain/usecases/create_service_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/delete_service_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/update_service_usecase.dart';

part 'service_action_event.dart';
part 'service_action_state.dart';

class ServiceActionBloc extends Bloc<ServiceActionEvent, ServiceActionState> {
  final CreateServiceUsecase createServiceUsecase;
  final UpdateServiceUsecase updateServiceUsecase;
  final DeleteServiceUsecase deleteServiceUsecase;

  ServiceActionBloc({
    required this.createServiceUsecase,
    required this.updateServiceUsecase,
    required this.deleteServiceUsecase,
  }) : super(ServiceActionInitial()) {
    on<CreateServiceActionRequest>((event, emit) async {
      emit(ServiceActionLoading());
      try {
        await createServiceUsecase.call(event.body);
        emit(ServiceActionSuccess(message: 'Berhasil menambah layanan'));
      } on ApiException catch (e) {
        emit(ServiceActionError(message: e.message));
      } catch (e) {
        emit(ServiceActionError(message: 'Gagal menambah layanan'));
      }
    });

    on<UpdateServiceActionRequest>((event, emit) async {
      emit(ServiceActionLoading());
      try {
        await updateServiceUsecase.call(event.id, event.body);
        emit(ServiceActionSuccess(message: 'Berhasil memperbarui layanan'));
      } on ApiException catch (e) {
        emit(ServiceActionError(message: e.message));
      } catch (e) {
        emit(ServiceActionError(message: 'Gagal memperbarui layanan'));
      }
    });

    on<DeleteServiceActionRequest>((event, emit) async {
      emit(ServiceActionLoading());
      try {
        await deleteServiceUsecase.call(event.id);
        emit(ServiceActionSuccess(message: 'Berhasil menghapus layanan'));
      } on ApiException catch (e) {
        emit(ServiceActionError(message: e.message));
      } catch (e) {
        emit(ServiceActionError(message: 'Gagal menghapus layanan'));
      }
    });
  }
}
