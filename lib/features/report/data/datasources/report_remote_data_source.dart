import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lavendera/config/base_url/base_url.dart';
import 'package:lavendera/core/error/api_error_handler.dart';

import '../models/financial_report_model.dart';

class ReportRemoteDataSource {
  final Dio dio;

  ReportRemoteDataSource({required this.dio});

  Future<FinancialReportModel> getFinancialReport({
    String? startDate,
    String? endDate,
    String? outletId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

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
        '$baseUrl/reports/financial',
        queryParameters: queryParams,
      );

      debugPrint('Get Financial Report Result: ${response.data}');

      final data = response.data['data'] is Map<String, dynamic>
          ? response.data['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final meta = response.data['meta'] is Map<String, dynamic>
          ? response.data['meta'] as Map<String, dynamic>
          : null;

      return FinancialReportModel.fromJson(data, meta);
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      throw ApiErrorHandler.fromDioException(e);
    }
  }
}
