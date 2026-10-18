import 'package:lavendera/features/auth/domain/repositories/auth_repository.dart';

class LoadDataUsecase {
  final AuthRepository authRepository;

  LoadDataUsecase(this.authRepository);

  Future<Map<String, dynamic>> call() async {
    final result = await authRepository.loadData();
    return result;
  }
}
