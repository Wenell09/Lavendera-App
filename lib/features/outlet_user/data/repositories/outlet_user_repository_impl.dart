import 'package:lavendera/features/outlet_user/data/datasources/outlet_user_remote_data_source.dart';
import 'package:lavendera/features/outlet_user/domain/entities/outlet_with_users.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_with_outlet.dart';
import 'package:lavendera/features/outlet_user/domain/repositories/outlet_user_repository.dart';

class OutletUserRepositoryImpl implements OutletUserRepository {
  final OutletUserRemoteDataSource remoteDataSource;
  OutletUserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OutletWithUsers> assignUserToOutlet(
    String outletId,
    String userId,
  ) async {
    return await remoteDataSource.assignUserToOutlet(outletId, userId);
  }

  @override
  Future<OutletWithUsers> getOutletUsers(
    String outletId, {
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    return await remoteDataSource.getOutletUsers(
      outletId,
      search: search,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<void> unassignUserFromOutlet(String outletId, String userId) async {
    await remoteDataSource.unassignUserFromOutlet(outletId, userId);
  }

  @override
  Future<UserWithOutlet> getUserOutlet(String userId) async {
    return await remoteDataSource.getUserOutlet(userId);
  }
}
