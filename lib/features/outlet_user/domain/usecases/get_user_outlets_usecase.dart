import 'package:lavendera/features/outlet_user/domain/entities/user_with_outlets.dart';
import 'package:lavendera/features/outlet_user/domain/repositories/outlet_user_repository.dart';

class GetUserOutletsUsecase {
  final OutletUserRepository repository;
  GetUserOutletsUsecase(this.repository);

  Future<UserWithOutlets> call(String userId) async {
    return await repository.getUserOutlets(userId);
  }
}
