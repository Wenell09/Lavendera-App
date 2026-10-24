import 'package:lavendera/features/outlet_user/domain/entities/outlet_with_users.dart';
import 'package:lavendera/features/outlet_user/domain/repositories/outlet_user_repository.dart';

class GetOutletUsersUsecase {
  final OutletUserRepository repository;
  GetOutletUsersUsecase(this.repository);

  Future<OutletWithUsers> call(
    String outletId, {
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getOutletUsers(outletId, search: search, page: page, limit: limit);
  }
}
