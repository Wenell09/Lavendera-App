import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/outlet_user/domain/entities/outlet_summary.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_summary.dart';
import 'package:lavendera/features/outlet_user/domain/usecases/get_outlet_users_usecase.dart';

part 'outlet_user_event.dart';
part 'outlet_user_state.dart';

class OutletUserBloc extends Bloc<OutletUserEvent, OutletUserState> {
  final GetOutletUsersUsecase _getOutletUsersUsecase;

  OutletUserBloc({required this._getOutletUsersUsecase})
    : super(OutletUserInitial()) {
    on<GetOutletUsersRequest>((event, emit) async {
      final isFirstPage = event.page == 1;
      List<UserSummary> currentUsers = [];

      if (state is OutletUserLoaded) {
        final loaded = state as OutletUserLoaded;
        currentUsers = loaded.users;
      } else if (state is OutletUserError) {
        currentUsers = (state as OutletUserError).cachedUsers ?? [];
      }

      if (isFirstPage) {
        emit(OutletUserLoading());
      }

      try {
        final result = await _getOutletUsersUsecase.call(
          event.outletId,
          search: event.search,
          page: event.page,
          limit: event.limit,
        );

        final newUsers = result.users;
        final hasMore = result.pagination != null 
            ? result.pagination!.page < result.pagination!.totalPages
            : newUsers.length >= event.limit;
        
        List<UserSummary> fullList;

        if (isFirstPage) {
          fullList = newUsers;
        } else {
          final existingIds = currentUsers.map((e) => e.id).toSet();
          final uniqueNew = newUsers.where((e) => !existingIds.contains(e.id)).toList();
          fullList = [...currentUsers, ...uniqueNew];
        }

        emit(
          OutletUserLoaded(
            users: fullList,
            outlet: result.outlet,
            currentPage: event.page,
            hasMorePages: hasMore,
          ),
        );
      } on ApiException catch (e) {
        emit(
          OutletUserError(
            message: e.message.isNotEmpty
                ? e.message
                : 'Gagal memuat pengguna outlet',
            cachedUsers: currentUsers,
          ),
        );
      } catch (e) {
        emit(
          OutletUserError(
            message: 'Gagal memuat pengguna outlet',
            cachedUsers: currentUsers,
          ),
        );
      }
    });
  }
}
