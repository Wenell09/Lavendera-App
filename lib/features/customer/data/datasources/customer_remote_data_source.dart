import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/models/pagination_model.dart';

import '../models/customer_model.dart';

class CustomerRemoteDataSource {
  final Dio dio;

  CustomerRemoteDataSource({required this.dio});

  Future<CustomerModel> createCustomer(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('$baseUrl/customers', data: body);
      debugPrint('Create Customer Result: ${response.data}');
      return CustomerModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Create Customer Error: $e');
      rethrow;
    }
  }

  Future<PaginatedResult<CustomerModel>> getCustomers({
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/customers',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      debugPrint('Get Customers Result: ${response.data}');
      final List list = response.data['data'] ?? [];
      final models = list.map((json) => CustomerModel.fromJson(json)).toList();
      
      Pagination? pagination;
      if (response.data['meta'] != null && response.data['meta']['pagination'] != null) {
        pagination = Pagination.fromJson(response.data['meta']['pagination']);
      }

      return PaginatedResult<CustomerModel>(
        data: models,
        pagination: pagination,
      );
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Get Customers Error: $e');
      rethrow;
    }
  }

  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final response = await dio.get('$baseUrl/customers/$id');
      debugPrint('Get Customer By Id Result: ${response.data}');
      return CustomerModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Get Customer By Id Error: $e');
      rethrow;
    }
  }

  Future<CustomerModel> updateCustomer(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.patch('$baseUrl/customers/$id', data: body);
      debugPrint('Update Customer Result: ${response.data}');
      return CustomerModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Update Customer Error: $e');
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      final response = await dio.delete('$baseUrl/customers/$id');
      debugPrint('Delete Customer Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Delete Customer Error: $e');
      rethrow;
    }
  }
}
