import 'package:dio/dio.dart';
import 'package:splitbill_frontend/app/core/storage/secure_storage_service.dart';

import '../errors/api_exception.dart';

class ApiClient {
  ApiClient(this._storage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://splitbill-7uls.onrender.com/api/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] as bool? ?? true;

          if (!requiresAuth) {
            handler.next(options);
            return;
          }

          final token = await _storage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final SecureStorageService _storage;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    bool requiresAuth = true,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  ApiException _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timed out. Please try again.',
          statusCode: statusCode,
        );

      case DioExceptionType.connectionError:
        return const ApiException(message: 'Unable to connect to the server.');

      case DioExceptionType.badResponse:
        return ApiException(
          message: _extractServerMessage(e.response),
          statusCode: statusCode,
        );

      default:
        return const ApiException(
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  String _extractServerMessage(Response<dynamic>? response) {
    final data = response?.data;

    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }

    return 'Server returned an error.';
  }
}
