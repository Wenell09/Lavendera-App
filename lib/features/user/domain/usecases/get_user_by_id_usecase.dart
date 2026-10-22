import 'package:lavendera/features/user/domain/entities/user.dart';
import 'package:lavendera/features/user/domain/repositories/user_repository.dart';

class GetUserByIdUsecase {
  final UserRepository repository;

  GetUserByIdUsecase(this.repository);

  Future<User> call(String id) async {
    return await repository.getUserById(id);
  }
}
