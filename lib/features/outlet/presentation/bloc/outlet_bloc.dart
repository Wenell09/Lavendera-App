import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/outlet/domain/entities/outlet.dart';
import 'package:lavendera/features/outlet/domain/usecases/get_outlets_usecase.dart';

part 'outlet_event.dart';
part 'outlet_state.dart';

class OutletBloc extends Bloc<OutletEvent, OutletState> {
  final GetOutletsUsecase _getOutletsUsecase;

  OutletBloc({
    required this._getOutletsUsecase,
  })  : super(OutletInitial()) {
    on<GetOutletsRequest>((event, emit) async {
      if (state is OutletPaginationLoading || state is OutletLoading) {
        return;
      }
      final isFirstPage = event.page == 1;
      List<Outlet> currentOutlets = [];
      if (state is OutletLoaded) {
        currentOutlets = (state as OutletLoaded).outlets;
      } else if (state is OutletError) {
        currentOutlets = (state as OutletError).cachedOutlets ?? [];
      }
      if (isFirstPage) {
        emit(OutletLoading());
      } else {
        emit(
          OutletPaginationLoading(
            outlets: currentOutlets,
            currentPage: (state is OutletLoaded)
                ? (state as OutletLoaded).currentPage
                : event.page - 1,
            hasMorePages: true,
          ),
        );
      }
      try {
        final result = await _getOutletsUsecase.call(
          search: event.search,
          page: event.page,
          limit: event.limit,
        );
        final newOutlets = result.data;
        final pagination = result.pagination;
        final bool hasMore;
        if (pagination != null) {
          hasMore = pagination.page < pagination.totalPages;
        } else {
          hasMore = newOutlets.length >= event.limit;
        }
        List<Outlet> fullList;
        if (isFirstPage) {
          fullList = newOutlets;
        } else {
          final existingIds = currentOutlets.map((e) => e.id).toSet();
          final uniqueNewOutlets = newOutlets
              .where((e) => !existingIds.contains(e.id))
              .toList();
          fullList = [...currentOutlets, ...uniqueNewOutlets];
        }
        emit(
          OutletLoaded(
            outlets: fullList,
            currentPage: event.page,
            hasMorePages: hasMore,
          ),
        );
      } on ApiException {
        emit(
          OutletError(
            message: 'Gagal memuat data outlet',
            cachedOutlets: currentOutlets,
          ),
        );
      } catch (e) {
        emit(
          OutletError(
            message: 'Gagal memuat data outlet',
            cachedOutlets: currentOutlets,
          ),
        );
      }
    });
  }
}
