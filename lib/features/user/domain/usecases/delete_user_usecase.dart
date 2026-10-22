import 'package:lavendera/features/user/domain/repositories/user_repository.dart';

class DeleteUserUsecase {
  final UserRepository repository;

  DeleteUserUsecase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteUser(id);
  }
}
