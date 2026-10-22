import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/service_category/domain/usecases/create_service_category_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/delete_service_category_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/update_service_category_usecase.dart';

part 'service_category_action_event.dart';
part 'service_category_action_state.dart';

class ServiceCategoryActionBloc
    extends Bloc<ServiceCategoryActionEvent, ServiceCategoryActionState> {
  final CreateServiceCategoryUsecase createServiceCategoryUsecase;
  final UpdateServiceCategoryUsecase updateServiceCategoryUsecase;
  final DeleteServiceCategoryUsecase deleteServiceCategoryUsecase;

  ServiceCategoryActionBloc({
    required this.createServiceCategoryUsecase,
    required this.updateServiceCategoryUsecase,
    required this.deleteServiceCategoryUsecase,
  }) : super(ServiceCategoryActionInitial()) {
    on<CreateServiceCategoryActionRequest>((event, emit) async {
      emit(ServiceCategoryActionLoading());
      try {
        await createServiceCategoryUsecase.call(event.body);
        emit(
          ServiceCategoryActionSuccess(
            message: 'Berhasil menambahkan kategori layanan',
          ),
        );
      } on ApiException catch (e) {
        emit(ServiceCategoryActionError(message: e.message));
      } catch (e) {
        emit(
          ServiceCategoryActionError(
            message: 'Gagal menambahkan kategori layanan',
          ),
        );
      }
    });

    on<UpdateServiceCategoryActionRequest>((event, emit) async {
      emit(ServiceCategoryActionLoading());
      try {
        await updateServiceCategoryUsecase.call(event.id, event.body);
        emit(
          ServiceCategoryActionSuccess(
            message: 'Berhasil memperbarui kategori layanan',
          ),
        );
      } on ApiException catch (e) {
        emit(ServiceCategoryActionError(message: e.message));
      } catch (e) {
        emit(
          ServiceCategoryActionError(
            message: 'Gagal memperbarui kategori layanan',
          ),
        );
      }
    });

    on<DeleteServiceCategoryActionRequest>((event, emit) async {
      emit(ServiceCategoryActionLoading());
      try {
        await deleteServiceCategoryUsecase.call(event.id);
        emit(
          ServiceCategoryActionSuccess(
            message: 'Berhasil menghapus kategori layanan',
          ),
        );
      } on ApiException catch (e) {
        emit(ServiceCategoryActionError(message: e.message));
      } catch (e) {
        emit(
          ServiceCategoryActionError(
            message: 'Gagal menghapus kategori layanan',
          ),
        );
      }
    });
  }
}
