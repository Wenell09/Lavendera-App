import 'package:lavendera/features/outlet_user/domain/repositories/outlet_user_repository.dart';

class UnassignUserFromOutletUsecase {
  final OutletUserRepository repository;
  UnassignUserFromOutletUsecase(this.repository);

  Future<void> call(String outletId, String userId) async {
    return await repository.unassignUserFromOutlet(outletId, userId);
  }
}
