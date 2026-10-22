import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/user/domain/entities/user.dart';
import 'package:lavendera/features/user/domain/repositories/user_repository.dart';

class GetUsersUsecase {
  final UserRepository repository;

  GetUsersUsecase(this.repository);

  Future<PaginatedResult<User>> call({String? search, int page = 1, int limit = 10}) async {
    return await repository.getUsers(search: search, page: page, limit: limit);
  }
}
