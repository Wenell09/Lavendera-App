import 'package:lavendera/core/models/pagination_model.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<User> createUser(Map<String, dynamic> body);
  Future<PaginatedResult<User>> getUsers({String? search, int page = 1, int limit = 10});
  Future<User> getUserById(String id);
  Future<User> updateUser(String id, Map<String, dynamic> body);
  Future<void> deleteUser(String id);
}
