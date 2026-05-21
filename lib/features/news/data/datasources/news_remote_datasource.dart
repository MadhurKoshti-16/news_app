import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/article_model.dart';

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return NewsRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

abstract interface class NewsRemoteDataSource {
  Future<List<ArticleModel>> getTopHeadlines({
    required String category,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  const NewsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ArticleModel>> getTopHeadlines({
    required String category,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          'country': 'us',
          'category': category == 'top' ? 'general' : category,
          'page': page,
          'pageSize': pageSize,
        },
      );

      return _parseArticles(response.data);
    } on DioException catch (e) {
      AppLogger.error('getTopHeadlines failed', error: e, tag: 'RemoteDS');
      rethrow; // Already mapped by Dio interceptor
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  @override
  Future<List<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/everything',
        queryParameters: {
          'q': query,
          'page': page,
          'pageSize': pageSize,
          'sortBy': 'publishedAt',
          'language': 'en',
        },
      );

      return _parseArticles(response.data);
    } on DioException catch (e) {
      AppLogger.error('searchArticles failed', error: e, tag: 'RemoteDS');
      rethrow;
    } catch (e) {
      throw NetworkException(message: e.toString());
    }
  }

  List<ArticleModel> _parseArticles(dynamic responseData) {
    final data = responseData as Map<String, dynamic>;

    if (data['status'] != 'ok') {
      throw ServerException(
        message: data['message'] ?? 'API error',
        statusCode: 400,
      );
    }

    final articles = (data['articles'] as List<dynamic>? ?? [])
        .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
        // Filter out articles with [Removed] titles (NewsAPI quirk)
        .where((a) => a.title != null && a.title != '[Removed]')
        .toList();

    return articles;
  }
}
