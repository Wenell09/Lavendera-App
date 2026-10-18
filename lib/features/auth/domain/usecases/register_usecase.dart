import 'package:lavendera/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<void> call(Map<String, dynamic> data) async {
    await repository.register(data);
  }
}
