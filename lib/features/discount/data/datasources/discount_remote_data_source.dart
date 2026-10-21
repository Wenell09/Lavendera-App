import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/discount/data/models/discount_model.dart';

class DiscountRemoteDataSource {
  final Dio dio;
  DiscountRemoteDataSource({required this.dio});

  Future<DiscountModel> createDiscount(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('$baseUrl/discounts', data: body);
      debugPrint('Create Discount Result: ${response.data}');
      return DiscountModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<PaginatedResult<DiscountModel>> getDiscounts({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/discounts',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      debugPrint('Get Discounts Result: ${response.data}');
      final List list = response.data['data'] ?? [];
      final models = list.map((json) => DiscountModel.fromJson(json)).toList();
      Pagination? pagination;
      if (response.data['meta'] != null &&
          response.data['meta']['pagination'] != null) {
        pagination = Pagination.fromJson(response.data['meta']['pagination']);
      }
      return PaginatedResult<DiscountModel>(
        data: models,
        pagination: pagination,
      );
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<DiscountModel> getDiscountById(String id) async {
    try {
      final response = await dio.get('$baseUrl/discounts/$id');
      debugPrint('Get Discount By Id Result: ${response.data}');
      return DiscountModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<DiscountModel> updateDiscount(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.patch('$baseUrl/discounts/$id', data: body);
      debugPrint('Update Discount Result: ${response.data}');
      return DiscountModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<void> deleteDiscount(String id) async {
    try {
      final response = await dio.delete('$baseUrl/discounts/$id');
      debugPrint('Delete Discount Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
