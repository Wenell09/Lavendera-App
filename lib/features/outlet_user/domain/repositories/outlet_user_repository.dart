import 'package:lavendera/features/outlet_user/domain/entities/outlet_with_users.dart';
import 'package:lavendera/features/outlet_user/domain/entities/user_with_outlets.dart';

abstract class OutletUserRepository {
  Future<OutletWithUsers> assignUserToOutlet(String outletId, String userId);
  Future<OutletWithUsers> getOutletUsers(String outletId, {String? search, int page = 1, int limit = 10});
  Future<void> unassignUserFromOutlet(String outletId, String userId);
  Future<UserWithOutlets> getUserOutlets(String userId);
}
