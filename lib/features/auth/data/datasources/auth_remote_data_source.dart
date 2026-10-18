import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lavendera/config/base_url/base_url.dart';

class AuthRemoteDataSource {
  final dio = Dio();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data['data'];
      final token = data['token'];
      final id = data['user']['id'];
      debugPrint('Token: $token');
      debugPrint('User ID: $id');
      return {'id': id, 'token': token};
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> register({required Map<String, dynamic> data}) async {
    try {
      final response = await dio.post('$baseUrl/auth/register', data: data);
      if (response.statusCode != 201) {
        throw Exception('Failed to register');
      }
      debugPrint('Registration successful: ${response.data}');
    } on DioException catch (e) {
      debugPrint('Status code: ${e.response?.statusCode}');
      debugPrint('Response error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      rethrow;
    }
  }
}
