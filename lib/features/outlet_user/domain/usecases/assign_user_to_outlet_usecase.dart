import 'package:lavendera/features/outlet_user/domain/entities/outlet_with_users.dart';
import 'package:lavendera/features/outlet_user/domain/repositories/outlet_user_repository.dart';

class AssignUserToOutletUsecase {
  final OutletUserRepository repository;
  AssignUserToOutletUsecase(this.repository);

  Future<OutletWithUsers> call(String outletId, String userId) async {
    return await repository.assignUserToOutlet(outletId, userId);
  }
}
