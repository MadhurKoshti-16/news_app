import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/exceptions.dart';
import '../utils/app_logger.dart';

/// Riverpod provider so Dio is injectable everywhere.
final dioClientProvider = Provider<Dio>((ref) {
  return DioClient.instance;
});

class DioClient {
  DioClient._();

  static final Dio instance = _createDio();

  static Dio _createDio() {
    final baseUrl = dotenv.env['NEWS_API_BASE_URL'] ?? 'https://newsapi.org/v2';
    final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['apiKey'] = apiKey;
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: false,
        responseBody: false,
        error: true,
        logPrint: (obj) => AppLogger.debug(obj.toString(), tag: 'DIO'),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          throw _mapDioException(e);
        },
      ),
    );

    return dio;
  }

  static Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(message: e.message ?? 'Connection error');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 401) {
          return const UnauthorizedException();
        }
        return ServerException(
          message: e.response?.data?['message'] ?? 'Server error',
          statusCode: statusCode,
        );

      default:
        return NetworkException(message: e.message ?? 'Unknown error');
    }
  }
}
