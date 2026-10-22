import 'package:bloc/bloc.dart';
import 'package:lavendera/core/error/api_exception.dart';
import 'package:lavendera/features/user/domain/entities/user.dart';
import 'package:lavendera/features/user/domain/usecases/get_users_usecase.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsersUsecase _getUsersUsecase;

  UserBloc({required this._getUsersUsecase}) : super(UserInitial()) {
    on<GetUsersRequest>((event, emit) async {
      if (state is UserPaginationLoading || state is UserLoading) {
        return;
      }
      final isFirstPage = event.page == 1;
      List<User> currentUsers = [];
      if (state is UserLoaded) {
        currentUsers = (state as UserLoaded).users;
      } else if (state is UserError) {
        currentUsers = (state as UserError).cachedUsers ?? [];
      }
      if (isFirstPage) {
        emit(UserLoading());
      } else {
        emit(
          UserPaginationLoading(
            users: currentUsers,
            currentPage: (state is UserLoaded)
                ? (state as UserLoaded).currentPage
                : event.page - 1,
            hasMorePages: true,
          ),
        );
      }
      try {
        final result = await _getUsersUsecase.call(
          search: event.search,
          page: event.page,
          limit: event.limit,
        );
        final newUsers = result.data;
        final pagination = result.pagination;
        final bool hasMore;
        if (pagination != null) {
          hasMore = pagination.page < pagination.totalPages;
        } else {
          hasMore = newUsers.length >= event.limit;
        }
        List<User> fullList;
        if (isFirstPage) {
          fullList = newUsers;
        } else {
          final existingIds = currentUsers.map((e) => e.id).toSet();
          final uniqueNewUsers =
              newUsers.where((e) => !existingIds.contains(e.id)).toList();
          fullList = [...currentUsers, ...uniqueNewUsers];
        }
        emit(
          UserLoaded(
            users: fullList,
            currentPage: event.page,
            hasMorePages: hasMore,
          ),
        );
      } on ApiException catch (e) {
        emit(
          UserError(
            message: e.message.isNotEmpty ? e.message : 'Gagal memuat data pengguna',
            cachedUsers: currentUsers,
          ),
        );
      } catch (e) {
        emit(
          UserError(
            message: 'Gagal memuat data pengguna',
            cachedUsers: currentUsers,
          ),
        );
      }
    });
  }
}
