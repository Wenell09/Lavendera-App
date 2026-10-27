import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/features/tenant/data/models/tenant_model.dart';

class TenantRemoteDataSource {
  final Dio dio;

  TenantRemoteDataSource({required this.dio});

  Future<TenantModel> getTenant(String id) async {
    try {
      final response = await dio.get('$baseUrl/tenants/$id');
      debugPrint('Get Tenant Result: ${response.data}');
      return TenantModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<TenantModel> updateTenant(String id, Map<String, dynamic> body) async {
    try {
      final response = await dio.patch('$baseUrl/tenants/$id', data: body);
      debugPrint('Update Tenant Result: ${response.data}');
      return TenantModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
