import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/news/data/models/article_model.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_local_datasource.dart';
import '../datasources/news_remote_datasource.dart';
import '../models/article_hive_model.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    remoteDataSource: ref.watch(newsRemoteDataSourceProvider),
    localDataSource: ref.watch(newsLocalDataSourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  @override
  Future<({Failure? failure, List<ArticleEntity>? data})> getTopHeadlines({
    required String category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final isOnline = await connectivityService.isConnected;

    if (isOnline) {
      try {
        final models = await remoteDataSource.getTopHeadlines(
          category: category,
          page: page,
          pageSize: pageSize,
        );

        final entities = models.map((m) => m.toEntity()).toList();

        if (page == 1) {
          final hiveModels = entities.map((e) => e.toHiveModel()).toList();
          await localDataSource.cacheArticles(category, hiveModels);
        }

        // Overlay bookmark state
        final withBookmarks = _overlayBookmarks(entities);
        return (failure: null, data: withBookmarks);
      } on ServerException catch (e) {
        AppLogger.error('Server error in getTopHeadlines', error: e);
        return (
          failure: Failure.server(message: e.message, statusCode: e.statusCode),
          data: null,
        );
      } on UnauthorizedException catch (e) {
        return (failure: Failure.unauthorized(message: e.message), data: null);
      } on NetworkException {
        return _getCachedHeadlines(category);
      } catch (e) {
        AppLogger.error('Unexpected error in getTopHeadlines', error: e);
        return (failure: Failure.unexpected(message: e.toString()), data: null);
      }
    } else {
      return _getCachedHeadlines(category);
    }
  }

  @override
  Future<({Failure? failure, List<ArticleEntity>? data})> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final models = await remoteDataSource.searchArticles(
        query: query,
        page: page,
        pageSize: pageSize,
      );
      final entities = _overlayBookmarks(
        models.map((m) => m.toEntity()).toList(),
      );
      return (failure: null, data: entities);
    } on ServerException catch (e) {
      return (
        failure: Failure.server(message: e.message, statusCode: e.statusCode),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: Failure.network(message: e.message), data: null);
    } catch (e) {
      return (failure: Failure.unexpected(message: e.toString()), data: null);
    }
  }

  @override
  Future<({Failure? failure, List<ArticleEntity>? data})> getBookmarks() async {
    try {
      final hiveModels = localDataSource.getBookmarks();
      final entities = hiveModels.map((m) => m.toEntity()).toList();
      return (failure: null, data: entities);
    } on CacheException catch (e) {
      return (failure: Failure.cache(message: e.message), data: null);
    }
  }

  @override
  Future<({Failure? failure, void data})> addBookmark(
    ArticleEntity article,
  ) async {
    try {
      await localDataSource.saveBookmark(
        article.copyWith(isBookmarked: true).toHiveModel(),
      );
      return (failure: null, data: null);
    } on CacheException catch (e) {
      return (failure: Failure.cache(message: e.message), data: null);
    }
  }

  @override
  Future<({Failure? failure, void data})> removeBookmark(
    String articleId,
  ) async {
    try {
      await localDataSource.deleteBookmark(articleId);
      return (failure: null, data: null);
    } on CacheException catch (e) {
      return (failure: Failure.cache(message: e.message), data: null);
    }
  }

  @override
  Future<bool> isBookmarked(String articleId) async {
    return localDataSource.isBookmarked(articleId);
  }

  @override
  Future<({Failure? failure, void data})> clearCache() async {
    try {
      await localDataSource.clearCache();
      return (failure: null, data: null);
    } on CacheException catch (e) {
      return (failure: Failure.cache(message: e.message), data: null);
    }
  }

  /// Overlays the current bookmark state from Hive onto a list of entities.
  List<ArticleEntity> _overlayBookmarks(List<ArticleEntity> entities) {
    return entities.map((e) {
      final bookmarked = localDataSource.isBookmarked(e.id);
      return bookmarked ? e.copyWith(isBookmarked: true) : e;
    }).toList();
  }

  /// Returns cached headlines for [category], or a [NetworkFailure].
  Future<({Failure? failure, List<ArticleEntity>? data})> _getCachedHeadlines(
    String category,
  ) async {
    try {
      final cached = localDataSource.getCachedArticles(category);
      if (cached.isEmpty) {
        return (
          failure: const Failure.network(
            message: 'No internet connection and no cached data available.',
          ),
          data: null,
        );
      }
      final entities = _overlayBookmarks(
        cached.map((m) => m.toEntity()).toList(),
      );
      return (failure: null, data: entities);
    } on CacheException catch (e) {
      return (failure: Failure.cache(message: e.message), data: null);
    }
  }
}
