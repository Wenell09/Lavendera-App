import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/features/outlet_user/data/models/outlet_with_users_model.dart';
import 'package:lavendera/features/outlet_user/data/models/user_with_outlets_model.dart';

class OutletUserRemoteDataSource {
  final Dio dio;
  OutletUserRemoteDataSource({required this.dio});

  Future<OutletWithUsersModel> assignUserToOutlet(
    String outletId,
    String userId,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/outlets/$outletId/users',
        data: {'outlet_id': outletId, 'user_id': userId},
      );
      debugPrint('Assign User Result: ${response.data}');
      return OutletWithUsersModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OutletWithUsersModel> getOutletUsers(
    String outletId, {
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/outlets/$outletId/users',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      debugPrint('Get Outlet Users Result: ${response.data}');
      return OutletWithUsersModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<void> unassignUserFromOutlet(String outletId, String userId) async {
    try {
      final response = await dio.delete(
        '$baseUrl/outlets/$outletId/users/$userId',
      );
      debugPrint('Unassign User Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<UserWithOutletsModel> getUserOutlet(String userId) async {
    try {
      final response = await dio.get('$baseUrl/users/$userId/outlets');
      debugPrint('Get User Outlets Result: ${response.data}');
      return UserWithOutletsModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
