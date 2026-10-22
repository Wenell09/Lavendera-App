import 'package:lavendera/features/user/domain/entities/user.dart';
import 'package:lavendera/features/user/domain/repositories/user_repository.dart';

class CreateUserUsecase {
  final UserRepository repository;

  CreateUserUsecase(this.repository);

  Future<User> call(Map<String, dynamic> body) async {
    return await repository.createUser(body);
  }
}
