import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/service_category/domain/entities/service_category.dart';
import 'package:lavendera/features/service_category/domain/usecases/get_service_categories_usecase.dart';

part 'service_category_event.dart';
part 'service_category_state.dart';

class ServiceCategoryBloc
    extends Bloc<ServiceCategoryEvent, ServiceCategoryState> {
  final GetServiceCategoriesUsecase getServiceCategoriesUsecase;

  ServiceCategoryBloc({
    required this.getServiceCategoriesUsecase,
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
  }
}
