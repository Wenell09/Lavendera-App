import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/user/data/models/user_model.dart';

class UserRemoteDataSource {
  final Dio dio;
  UserRemoteDataSource({required this.dio});

  Future<UserModel> createUser(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('$baseUrl/users', data: body);
      debugPrint('Create User Result: ${response.data}');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<PaginatedResult<UserModel>> getUsers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/users',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      debugPrint('Get Users Result: ${response.data}');
      final List list = response.data['data'] ?? [];
      final models = list.map((json) => UserModel.fromJson(json)).toList();
      Pagination? pagination;
      if (response.data['meta'] != null &&
          response.data['meta']['pagination'] != null) {
        pagination = Pagination.fromJson(response.data['meta']['pagination']);
      }
      return PaginatedResult<UserModel>(
        data: models,
        pagination: pagination,
      );
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      final response = await dio.get('$baseUrl/users/$id');
      debugPrint('Get User By Id Result: ${response.data}');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<UserModel> updateUser(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.patch('$baseUrl/users/$id', data: body);
      debugPrint('Update User Result: ${response.data}');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final response = await dio.delete('$baseUrl/users/$id');
      debugPrint('Delete User Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
