import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/service_category/domain/entities/service_category.dart';
import 'package:lavendera/features/service_category/domain/usecases/create_service_category_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/delete_service_category_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/get_service_categories_usecase.dart';
import 'package:lavendera/features/service_category/domain/usecases/update_service_category_usecase.dart';

part 'service_category_event.dart';
part 'service_category_state.dart';

class ServiceCategoryBloc
    extends Bloc<ServiceCategoryEvent, ServiceCategoryState> {
  final GetServiceCategoriesUsecase getServiceCategoriesUsecase;
  final CreateServiceCategoryUsecase createServiceCategoryUsecase;
  final UpdateServiceCategoryUsecase updateServiceCategoryUsecase;
  final DeleteServiceCategoryUsecase deleteServiceCategoryUsecase;

  ServiceCategoryBloc({
    required this.getServiceCategoriesUsecase,
    required this.createServiceCategoryUsecase,
    required this.updateServiceCategoryUsecase,
    required this.deleteServiceCategoryUsecase,
  }) : super(ServiceCategoryInitial()) {
    on<GetServiceCategoriesRequest>((event, emit) async {
      List<ServiceCategory> currentCategories = [];
      if (state is ServiceCategoryLoaded) {
        currentCategories = (state as ServiceCategoryLoaded).categories;
      } else if (state is ServiceCategoryError) {
        currentCategories =
            (state as ServiceCategoryError).cachedCategories ?? [];
      }
      emit(ServiceCategoryLoading());
      try {
        final categories = await getServiceCategoriesUsecase.call();
        emit(ServiceCategoryLoaded(categories: categories));
      } on ApiException {
        emit(
          ServiceCategoryError(
            message: 'Gagal memuat kategori layanan',
            cachedCategories: currentCategories,
          ),
        );
      } catch (e) {
        emit(
          ServiceCategoryError(
            message: 'Gagal memuat kategori layanan',
            cachedCategories: currentCategories,
          ),
        );
      }
    });

    on<CreateServiceCategoryRequest>((event, emit) async {
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

    on<UpdateServiceCategoryRequest>((event, emit) async {
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

    on<DeleteServiceCategoryRequest>((event, emit) async {
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
