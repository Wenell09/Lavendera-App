import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/models/pagination_model.dart';
import '../models/service_model.dart';

class ServiceRemoteDataSource {
  final Dio dio;

  ServiceRemoteDataSource({required this.dio});

  Future<PaginatedResult<ServiceModel>> getServices({
    String? search,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/services',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryId != null && categoryId.isNotEmpty)
            'category_id': categoryId,
          'page': page,
          'limit': limit,
        },
      );
      debugPrint('Get Services Result: ${response.data}');
      final List list = response.data['data'] ?? [];
      final models = list.map((json) => ServiceModel.fromJson(json)).toList();

      Pagination? pagination;
      if (response.data['meta'] != null &&
          response.data['meta']['pagination'] != null) {
        pagination = Pagination.fromJson(response.data['meta']['pagination']);
      }

      return PaginatedResult<ServiceModel>(
        data: models,
        pagination: pagination,
      );
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Get Services Error: $e');
      rethrow;
    }
  }

  Future<ServiceModel> getServiceById(String id) async {
    try {
      final response = await dio.get('$baseUrl/services/$id');
      debugPrint('Get Service By Id Result: ${response.data}');
      return ServiceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Get Service By Id Error: $e');
      rethrow;
    }
  }

  Future<ServiceModel> createService(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('$baseUrl/services', data: body);
      debugPrint('Create Service Result: ${response.data}');
      return ServiceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Create Service Error: $e');
      rethrow;
    }
  }

  Future<ServiceModel> updateService(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.patch('$baseUrl/services/$id', data: body);
      debugPrint('Update Service Result: ${response.data}');
      return ServiceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Update Service Error: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      final response = await dio.delete('$baseUrl/services/$id');
      debugPrint('Delete Service Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Delete Service Error: $e');
      rethrow;
    }
  }
}
