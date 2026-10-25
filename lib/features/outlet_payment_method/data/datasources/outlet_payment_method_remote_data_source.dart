import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';
import 'package:lavendera/core/models/pagination_model.dart';
import 'package:lavendera/features/outlet_payment_method/data/models/outlet_payment_method_model.dart';

class OutletPaymentMethodRemoteDataSource {
  final Dio dio;

  OutletPaymentMethodRemoteDataSource({required this.dio});

  Future<OutletPaymentMethodModel> createOutletPaymentMethod(
    String outletId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/outlets/$outletId/payment-methods',
        data: body,
      );
      debugPrint('Create Outlet Payment Method Result: ${response.data}');
      return OutletPaymentMethodModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<PaginatedResult<OutletPaymentMethodModel>> getOutletPaymentMethods(
    String outletId, {
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/outlets/$outletId/payment-methods',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      debugPrint('Get Outlet Payment Methods Result: ${response.data}');
      final List list = response.data['data'] ?? [];
      final models =
          list.map((json) => OutletPaymentMethodModel.fromJson(json)).toList();
      Pagination? pagination;
      if (response.data['meta'] != null &&
          response.data['meta']['pagination'] != null) {
        pagination = Pagination.fromJson(response.data['meta']['pagination']);
      }
      return PaginatedResult<OutletPaymentMethodModel>(
        data: models,
        pagination: pagination,
      );
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OutletPaymentMethodModel> getOutletPaymentMethodById(
    String outletId,
    String paymentMethodId,
  ) async {
    try {
      final response = await dio.get(
        '$baseUrl/outlets/$outletId/payment-methods/$paymentMethodId',
      );
      debugPrint('Get Outlet Payment Method By Id Result: ${response.data}');
      return OutletPaymentMethodModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<OutletPaymentMethodModel> updateOutletPaymentMethod(
    String outletId,
    String paymentMethodId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.patch(
        '$baseUrl/outlets/$outletId/payment-methods/$paymentMethodId',
        data: body,
      );
      debugPrint('Update Outlet Payment Method Result: ${response.data}');
      return OutletPaymentMethodModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<void> deleteOutletPaymentMethod(
    String outletId,
    String paymentMethodId,
  ) async {
    try {
      final response = await dio.delete(
        '$baseUrl/outlets/$outletId/payment-methods/$paymentMethodId',
      );
      debugPrint('Delete Outlet Payment Method Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }

  Future<void> uploadQrisImage(
    String outletId,
    String paymentMethodId,
    String filePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        '$baseUrl/outlets/$outletId/payment-methods/$paymentMethodId/qr-image',
        data: formData,
      );
      debugPrint('Upload QRIS Image Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Upload QRIS Status code: ${e.response?.statusCode}');
      debugPrint('Upload QRIS Response error: ${e.response?.data}');
    } catch (e) {
      debugPrint('Upload QRIS error: $e');
    }
  }

  Future<void> deleteQrisImage(
    String outletId,
    String paymentMethodId,
  ) async {
    try {
      final response = await dio.delete(
        '$baseUrl/outlets/$outletId/payment-methods/$paymentMethodId/qr-image',
      );
      debugPrint('Delete QRIS Image Result: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Delete QRIS Status code: ${e.response?.statusCode}');
      debugPrint('Delete QRIS Response error: ${e.response?.data}');
    } catch (e) {
      debugPrint('Delete QRIS error: $e');
    }
  }
}
