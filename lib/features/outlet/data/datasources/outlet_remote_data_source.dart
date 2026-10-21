import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/outlet/data/models/outlet_model.dart';

class OutletRemoteDataSource {
  final Dio dio;
  OutletRemoteDataSource({required this.dio});

  Future<OutletModel> createOutlet(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('$baseUrl/outlets', data: body);
      debugPrint('Create Outlet Result: ${response.data}');
      return OutletModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<PaginatedResult<OutletModel>> getOutlets({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/outlets',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      debugPrint('Get Outlets Result: ${response.data}');
      final List list = response.data['data'] ?? [];
      final models = list.map((json) => OutletModel.fromJson(json)).toList();
      Pagination? pagination;
      if (response.data['meta'] != null &&
          response.data['meta']['pagination'] != null) {
        pagination = Pagination.fromJson(response.data['meta']['pagination']);
      }
      return PaginatedResult<OutletModel>(data: models, pagination: pagination);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OutletModel> getOutletById(String id) async {
    try {
      final response = await dio.get('$baseUrl/outlets/$id');
      debugPrint('Get Outlet By Id Result: ${response.data}');
      return OutletModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OutletModel> updateOutlet(String id, Map<String, dynamic> body) async {
    try {
      final response = await dio.patch('$baseUrl/outlets/$id', data: body);
      debugPrint('Update Outlet Result: ${response.data}');
      return OutletModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<void> deleteOutlet(String id) async {
    try {
      final response = await dio.delete('$baseUrl/outlets/$id');
      debugPrint('Delete Outlet Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
