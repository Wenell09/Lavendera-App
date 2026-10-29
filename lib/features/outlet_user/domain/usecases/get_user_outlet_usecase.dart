import 'package:lavendera/features/outlet_user/domain/entities/user_with_outlet.dart';
import 'package:lavendera/features/outlet_user/domain/repositories/outlet_user_repository.dart';

class GetUserOutletUsecase {
  final OutletUserRepository repository;
  GetUserOutletUsecase(this.repository);

  Future<UserWithOutlet> call(String userId) async {
    return await repository.getUserOutlet(userId);
  }
}
