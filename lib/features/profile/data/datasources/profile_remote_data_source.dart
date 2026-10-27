import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/features/profile/data/models/profile_model.dart';

class ProfileRemoteDataSource {
  final Dio dio;
  ProfileRemoteDataSource({required this.dio});

  Future<ProfileModel> getProfile(String id) async {
    try {
      final response = await dio.get('$baseUrl/users/$id');
      debugPrint('Get Profile Result: ${response.data}');
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
