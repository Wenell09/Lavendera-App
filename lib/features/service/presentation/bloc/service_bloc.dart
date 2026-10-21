import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/service/domain/entities/service_item.dart';
import 'package:lavendera/features/service/domain/usecases/create_service_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/delete_service_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/get_services_usecase.dart';
import 'package:lavendera/features/service/domain/usecases/update_service_usecase.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetServicesUsecase getServicesUsecase;
  final CreateServiceUsecase createServiceUsecase;
  final UpdateServiceUsecase updateServiceUsecase;
  final DeleteServiceUsecase deleteServiceUsecase;

  ServiceBloc({
    required this.getServicesUsecase,
    required this.createServiceUsecase,
    required this.updateServiceUsecase,
    required this.deleteServiceUsecase,
  }) : super(ServiceInitial()) {
    on<GetServicesRequest>((event, emit) async {
      if (state is ServicePaginationLoading || state is ServiceLoading) {
        return;
      }
      final isFirstPage = event.page == 1;
      List<LaundryService> currentServices = [];
      if (state is ServiceLoaded) {
        currentServices = (state as ServiceLoaded).services;
      } else if (state is ServiceError) {
        currentServices = (state as ServiceError).cachedServices ?? [];
      }
      if (isFirstPage) {
        emit(ServiceLoading());
      } else {
        emit(
          ServicePaginationLoading(
            services: currentServices,
            currentPage: (state is ServiceLoaded)
                ? (state as ServiceLoaded).currentPage
                : event.page - 1,
            hasMorePages: true,
          ),
        );
      }
      try {
        final result = await getServicesUsecase.call(
          search: event.search,
          categoryId: event.categoryId,
          page: event.page,
          limit: event.limit,
        );
        final newServices = result.data;
        final pagination = result.pagination;
        final bool hasMore;
        if (pagination != null) {
          hasMore = pagination.page < pagination.totalPages;
        } else {
          hasMore = newServices.length >= event.limit;
        }
        List<LaundryService> fullList;
        if (isFirstPage) {
          fullList = newServices;
        } else {
          final existingIds = currentServices.map((e) => e.id).toSet();
          final uniqueNewServices = newServices
              .where((e) => !existingIds.contains(e.id))
              .toList();
          fullList = [...currentServices, ...uniqueNewServices];
        }
        emit(
          ServiceLoaded(
            services: fullList,
            currentPage: event.page,
            hasMorePages: hasMore,
          ),
        );
      } on ApiException catch (e) {
        emit(ServiceError(message: e.message, cachedServices: currentServices));
      } catch (e) {
        emit(
          ServiceError(
            message: 'Gagal memuat data layanan',
            cachedServices: currentServices,
          ),
        );
      }
    });

    on<CreateServiceRequest>((event, emit) async {
      emit(ServiceLoading());
      try {
        await createServiceUsecase.call(event.body);
        emit(ServiceActionSuccess(message: 'Berhasil menambah layanan'));
      } on ApiException catch (e) {
        emit(ServiceError(message: e.message));
      } catch (e) {
        emit(ServiceError(message: 'Gagal menambah layanan'));
      }
    });

    on<UpdateServiceRequest>((event, emit) async {
      emit(ServiceLoading());
      try {
        await updateServiceUsecase.call(event.id, event.body);
        emit(ServiceActionSuccess(message: 'Berhasil memperbarui layanan'));
      } on ApiException catch (e) {
        emit(ServiceError(message: e.message));
      } catch (e) {
        emit(ServiceError(message: 'Gagal memperbarui layanan'));
      }
    });

    on<DeleteServiceRequest>((event, emit) async {
      emit(ServiceLoading());
      try {
        await deleteServiceUsecase.call(event.id);
        emit(ServiceActionSuccess(message: 'Berhasil menghapus layanan'));
      } on ApiException catch (e) {
        emit(ServiceError(message: e.message));
      } catch (e) {
        emit(ServiceError(message: 'Gagal menghapus layanan'));
      }
    });
  }
}
