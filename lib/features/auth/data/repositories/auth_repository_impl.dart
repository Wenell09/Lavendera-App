import 'package:lavendera/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:lavendera/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:lavendera/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await authRemoteDataSource.login(
      email: email,
      password: password,
    );
    await authLocalDataSource.saveSession(
      id: response["id"],
      token: response["token"],
    );
    return response;
  }

  @override
  Future<void> register(Map<String, dynamic> data) async {
    await authRemoteDataSource.register(data: data);
  }

  @override
  Future<void> signOut() async {
    await authLocalDataSource.clearSession();
  }

  @override
  Future<Map<String, dynamic>> loadData() async {
    final token = await authLocalDataSource.getToken();
    final userId = await authLocalDataSource.getUserId();
    final Map<String, dynamic> response = {"token": token, "id": userId};
    return response;
  }
}
