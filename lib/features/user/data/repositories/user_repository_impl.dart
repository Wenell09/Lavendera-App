import 'package:lavendera/core/models/pagination_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> createUser(Map<String, dynamic> body) async {
    final model = await remoteDataSource.createUser(body);
    return model.toEntity();
  }

  @override
  Future<PaginatedResult<User>> getUsers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final result = await remoteDataSource.getUsers(
      search: search,
      page: page,
      limit: limit,
    );
    return PaginatedResult<User>(
      data: result.data.map((model) => model.toEntity()).toList(),
      pagination: result.pagination,
    );
  }

  @override
  Future<User> getUserById(String id) async {
    final model = await remoteDataSource.getUserById(id);
    return model.toEntity();
  }

  @override
  Future<User> updateUser(String id, Map<String, dynamic> body) async {
    final model = await remoteDataSource.updateUser(id, body);
    return model.toEntity();
  }

  @override
  Future<void> deleteUser(String id) async {
    await remoteDataSource.deleteUser(id);
  }
}
