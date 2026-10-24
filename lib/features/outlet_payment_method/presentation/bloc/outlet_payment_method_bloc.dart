import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/outlet_payment_method/domain/entities/outlet_payment_method.dart';
import 'package:lavendera/features/outlet_payment_method/domain/usecases/get_outlet_payment_methods_usecase.dart';

part 'outlet_payment_method_event.dart';
part 'outlet_payment_method_state.dart';

class OutletPaymentMethodBloc
    extends Bloc<OutletPaymentMethodEvent, OutletPaymentMethodState> {
  final GetOutletPaymentMethodsUsecase _getOutletPaymentMethodsUsecase;

  OutletPaymentMethodBloc({
    required this._getOutletPaymentMethodsUsecase,
  })  : super(OutletPaymentMethodInitial()) {
    on<GetOutletPaymentMethodsRequest>((event, emit) async {
      if (state is OutletPaymentMethodPaginationLoading ||
          state is OutletPaymentMethodLoading) {
        return;
      }

      final isFirstPage = event.page == 1;
      List<OutletPaymentMethod> currentList = [];

      if (state is OutletPaymentMethodLoaded) {
        currentList = (state as OutletPaymentMethodLoaded).paymentMethods;
      } else if (state is OutletPaymentMethodError) {
        currentList = (state as OutletPaymentMethodError).cachedPaymentMethods ?? [];
      }

      if (isFirstPage) {
        emit(OutletPaymentMethodLoading());
      } else {
        emit(
          OutletPaymentMethodPaginationLoading(
            paymentMethods: currentList,
            currentPage: (state is OutletPaymentMethodLoaded)
                ? (state as OutletPaymentMethodLoaded).currentPage
                : event.page - 1,
            hasMorePages: true,
          ),
        );
      }

      try {
        final result = await _getOutletPaymentMethodsUsecase.call(
          event.outletId,
          search: event.search,
          page: event.page,
          limit: event.limit,
        );

        final newList = result.data;
        final pagination = result.pagination;
        final bool hasMore;

        if (pagination != null) {
          hasMore = pagination.page < pagination.totalPages;
        } else {
          hasMore = newList.length >= event.limit;
        }

        List<OutletPaymentMethod> fullList;
        if (isFirstPage) {
          fullList = newList;
        } else {
          final existingIds = currentList.map((e) => e.id).toSet();
          final uniqueNewItems =
              newList.where((e) => !existingIds.contains(e.id)).toList();
          fullList = [...currentList, ...uniqueNewItems];
        }

        emit(
          OutletPaymentMethodLoaded(
            paymentMethods: fullList,
            currentPage: event.page,
            hasMorePages: hasMore,
          ),
        );
      } on ApiException catch (e) {
        emit(
          OutletPaymentMethodError(
            message: e.message.isNotEmpty
                ? e.message
                : 'Gagal memuat metode pembayaran',
            cachedPaymentMethods: currentList,
          ),
        );
      } catch (e) {
        emit(
          OutletPaymentMethodError(
            message: 'Gagal memuat metode pembayaran',
            cachedPaymentMethods: currentList,
          ),
        );
      }
    });
  }
}
