import 'package:lavendera/features/user/domain/entities/user.dart';
import 'package:lavendera/features/user/domain/repositories/user_repository.dart';

class UpdateUserUsecase {
  final UserRepository repository;

  UpdateUserUsecase(this.repository);

  Future<User> call(String id, Map<String, dynamic> body) async {
    return await repository.updateUser(id, body);
  }
}
