import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';

import '../models/dashboard_model.dart';

class DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSource({required this.dio});

  Future<DashboardModel> getDashboard({
    String? startDate,
    String? endDate,
    String? outletId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null && startDate.trim().isNotEmpty) {
        queryParams['start_date'] = startDate.trim();
      }
      if (endDate != null && endDate.trim().isNotEmpty) {
        queryParams['end_date'] = endDate.trim();
      }
      if (outletId != null && outletId.trim().isNotEmpty) {
        queryParams['outlet_id'] = outletId.trim();
      }

      final response = await dio.get(
        '$baseUrl/dashboard',
        queryParameters: queryParams,
      );

      debugPrint('Get Dashboard Result: ${response.data}');

      final data = response.data['data'] is Map<String, dynamic>
          ? response.data['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      return DashboardModel.fromJson(data);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
