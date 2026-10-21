import 'package:dio/dio.dart';

import 'api_exception.dart';

class ApiErrorHandler {
  static ApiException fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          statusCode: null,
          message: 'Koneksi ke server mengalami timeout.',
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          statusCode: null,
          message:
              'Tidak dapat terhubung ke server. '
              'Periksa koneksi internet kamu.',
        );

      case DioExceptionType.cancel:
        return const ApiException(
          statusCode: null,
          message: 'Permintaan dibatalkan.',
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          statusCode: null,
          message: 'Sertifikat keamanan server bermasalah.',
        );

      case DioExceptionType.badResponse:
        return ApiException(
          statusCode: statusCode,
          message: _messageFromStatusCode(statusCode),
        );

      case DioExceptionType.unknown:
        return const ApiException(
          statusCode: null,
          message: 'Terjadi kesalahan yang tidak terduga.',
        );
      case DioExceptionType.transformTimeout:
        return const ApiException(
          statusCode: null,
          message: 'Terjadi kesalahan yang tidak terduga.',
        );
    }
  }

  static String _messageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid. Periksa kembali data kamu.';

      case 401:
        return 'Sesi login berakhir. Silakan login kembali.';

      case 403:
        return 'Kamu tidak memiliki izin untuk melakukan tindakan ini.';

      case 404:
        return 'Data tidak ditemukan.';

      case 405:
        return 'Operasi ini tidak diizinkan.';

      case 409:
        return 'Data sudah tersedia.';

      case 413:
        return 'Ukuran data yang dikirim terlalu besar.';

      case 422:
        return 'Data yang dikirim tidak dapat diproses.';

      case 429:
        return 'Terlalu banyak permintaan. Coba lagi nanti.';

      case 500:
        return 'Terjadi kesalahan pada server.';

      case 502:
      case 503:
      case 504:
        return 'Layanan sedang mengalami gangguan. Coba lagi nanti.';

      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Terjadi kesalahan pada server.';
        }

        return 'Terjadi kesalahan. Silakan coba kembali.';
    }
  }
}
