import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/core/models/pagination_model.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSource({required this.dio});

  Future<OrderModel> createOrder(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('$baseUrl/orders', data: body);
      debugPrint('Create Order Result: ${response.data}');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<PaginatedResult<OrderModel>> getOrders({
    String? search,
    String? status,
    String? outletId,
    String? customerId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (status != null && status.trim().isNotEmpty) {
        queryParams['status'] = status.trim();
      }
      if (outletId != null && outletId.trim().isNotEmpty) {
        queryParams['outlet_id'] = outletId.trim();
      }
      if (customerId != null && customerId.trim().isNotEmpty) {
        queryParams['customer_id'] = customerId.trim();
      }
      if (startDate != null && startDate.trim().isNotEmpty) {
        queryParams['start_date'] = startDate.trim();
      }
      if (endDate != null && endDate.trim().isNotEmpty) {
        queryParams['end_date'] = endDate.trim();
      }

      final response = await dio.get(
        '$baseUrl/orders',
        queryParameters: queryParams,
      );
      debugPrint('Get Orders Result: ${response.data}');
      final List list = response.data['data'] ?? [];
      final models = list.map((json) => OrderModel.fromJson(json)).toList();

      Pagination? pagination;
      if (response.data['meta'] != null &&
          response.data['meta']['pagination'] != null) {
        pagination = Pagination.fromJson(response.data['meta']['pagination']);
      }

      return PaginatedResult<OrderModel>(
        data: models,
        pagination: pagination,
      );
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await dio.get('$baseUrl/orders/$id');
      debugPrint('Get Order By Id Result: ${response.data}');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OrderModel> updateOrderStatus(String id, String status) async {
    try {
      final response = await dio.patch(
        '$baseUrl/orders/$id/status',
        data: {'status': status},
      );
      debugPrint('Update Order Status Result: ${response.data}');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OrderModel> cancelOrder(String id) async {
    try {
      final response = await dio.patch('$baseUrl/orders/$id/cancel');
      debugPrint('Cancel Order Result: ${response.data}');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OrderModel> confirmPayment(String orderId, String paymentId) async {
    try {
      final response = await dio.patch(
        '$baseUrl/orders/$orderId/payments/$paymentId/confirm',
      );
      debugPrint('Confirm Payment Result: ${response.data}');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OrderModel> inputCashPayment(String orderId, num paidAmount) async {
    try {
      final response = await dio.patch(
        '$baseUrl/orders/$orderId/cash-payment',
        data: {'paid_amount': paidAmount},
      );
      debugPrint('Input Cash Payment Result: ${response.data}');
      return OrderModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
