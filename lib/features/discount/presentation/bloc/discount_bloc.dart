import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/discount/domain/entities/discount.dart';
import 'package:lavendera/features/discount/domain/usecases/get_discounts_usecase.dart';

part 'discount_event.dart';
part 'discount_state.dart';

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final GetDiscountsUsecase _getDiscountsUsecase;

  DiscountBloc({
    required this._getDiscountsUsecase,
  })  : super(DiscountInitial()) {
    on<GetDiscountsRequest>((event, emit) async {
      if (state is DiscountPaginationLoading || state is DiscountLoading) {
        return;
      }
      final isFirstPage = event.page == 1;
      List<Discount> currentDiscounts = [];
      if (state is DiscountLoaded) {
        currentDiscounts = (state as DiscountLoaded).discounts;
      } else if (state is DiscountError) {
        currentDiscounts = (state as DiscountError).cachedDiscounts ?? [];
      }
      if (isFirstPage) {
        emit(DiscountLoading());
      } else {
        emit(
          DiscountPaginationLoading(
            discounts: currentDiscounts,
            currentPage: (state is DiscountLoaded)
                ? (state as DiscountLoaded).currentPage
                : event.page - 1,
            hasMorePages: true,
          ),
        );
      }
      try {
        final result = await _getDiscountsUsecase.call(
          search: event.search,
          page: event.page,
          limit: event.limit,
        );
        final newDiscounts = result.data;
        final pagination = result.pagination;
        final bool hasMore;
        if (pagination != null) {
          hasMore = pagination.page < pagination.totalPages;
        } else {
          hasMore = newDiscounts.length >= event.limit;
        }
        List<Discount> fullList;
        if (isFirstPage) {
          fullList = newDiscounts;
        } else {
          final existingIds = currentDiscounts.map((e) => e.id).toSet();
          final uniqueNewDiscounts = newDiscounts
              .where((e) => !existingIds.contains(e.id))
              .toList();
          fullList = [...currentDiscounts, ...uniqueNewDiscounts];
        }
        emit(
          DiscountLoaded(
            discounts: fullList,
            currentPage: event.page,
            hasMorePages: hasMore,
          ),
        );
      } on ApiException {
        emit(
          DiscountError(
            message: 'Gagal memuat data diskon',
            cachedDiscounts: currentDiscounts,
          ),
        );
      } catch (e) {
        emit(
          DiscountError(
            message: 'Gagal memuat data diskon',
            cachedDiscounts: currentDiscounts,
          ),
        );
      }
    });
  }
}
