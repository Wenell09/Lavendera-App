import 'package:lavendera/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Map<String, dynamic>> call(String email, String password) async {
    final result = await repository.login(email, password);
    return result;
  }
}
