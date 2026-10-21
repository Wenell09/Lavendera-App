import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/features/service_category/data/models/service_category_model.dart';

class ServiceCategoryRemoteDataSource {
  final Dio dio;
  ServiceCategoryRemoteDataSource({required this.dio});

  Future<List<ServiceCategoryModel>> getServiceCategories() async {
    try {
      final response = await dio.get('$baseUrl/service-categories');
      debugPrint('Get Service Categories Result: ${response.data}');
      final List list = response.data['data'] ?? [];
      return list.map((json) => ServiceCategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<ServiceCategoryModel> getServiceCategoryById(String id) async {
    try {
      final response = await dio.get('$baseUrl/service-categories/$id');
      debugPrint('Get Service Category By Id Result: ${response.data}');
      return ServiceCategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<ServiceCategoryModel> createServiceCategory(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/service-categories',
        data: body,
      );
      debugPrint('Create Service Category Result: ${response.data}');
      return ServiceCategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<ServiceCategoryModel> updateServiceCategory(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.patch(
        '$baseUrl/service-categories/$id',
        data: body,
      );
      debugPrint('Update Service Category Result: ${response.data}');
      return ServiceCategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<void> deleteServiceCategory(String id) async {
    try {
      final response = await dio.delete('$baseUrl/service-categories/$id');
      debugPrint('Delete Service Category Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
