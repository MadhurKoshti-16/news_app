// test/features/news/data/repositories/news_repository_impl_test.dart
//
// Unit tests for NewsRepositoryImpl — the orchestration layer.
// Mocks remote DS, local DS, and connectivity service.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/exceptions.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/core/network/connectivity_service.dart';
import 'package:news_app/features/news/data/datasources/news_local_datasource.dart';
import 'package:news_app/features/news/data/datasources/news_remote_datasource.dart';
import 'package:news_app/features/news/data/models/article_hive_model.dart';
import 'package:news_app/features/news/data/models/article_model.dart';
import 'package:news_app/features/news/data/repositories/news_repository_impl.dart';
import 'package:news_app/features/news/domain/entities/article_entity.dart';

class MockRemoteDS extends Mock implements NewsRemoteDataSource {}

class MockLocalDS extends Mock implements NewsLocalDataSource {}

class MockConnectivity extends Mock implements ConnectivityService {}

ArticleModel _articleModel(String id) => ArticleModel(
  source: const ArticleSourceModel(id: 's', name: 'Source'),
  author: 'A',
  title: 'Title $id',
  url: 'https://example.com/$id',
  publishedAt: '2024-01-01T00:00:00Z',
  content: 'Content for $id',
);

ArticleHiveModel _hiveModel(String id) => ArticleHiveModel(
  id: 'https://example.com/$id',
  title: 'Title $id',
  url: 'https://example.com/$id',
  sourceName: 'Source',
  publishedAt: DateTime(2024),
  readTime: '1 min read',
);

void main() {
  late MockRemoteDS remote;
  late MockLocalDS local;
  late MockConnectivity connectivity;
  late NewsRepositoryImpl repo;

  setUp(() {
    remote = MockRemoteDS();
    local = MockLocalDS();
    connectivity = MockConnectivity();

    repo = NewsRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      connectivityService: connectivity,
    );

    // Default: isBookmarked returns false
    when(() => local.isBookmarked(any())).thenReturn(false);
  });

  group('getTopHeadlines() — online', () {
    setUp(() {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
    });

    test('returns mapped entities and caches on page 1', () async {
      when(
        () =>
            remote.getTopHeadlines(category: 'general', page: 1, pageSize: 20),
      ).thenAnswer((_) async => [_articleModel('1'), _articleModel('2')]);
      when(() => local.cacheArticles(any(), any())).thenAnswer((_) async {});

      final result = await repo.getTopHeadlines(category: 'general');

      expect(result.failure, isNull);
      expect(result.data, hasLength(2));
      verify(() => local.cacheArticles('general', any())).called(1);
    });

    test('does NOT cache on page 2 (pagination)', () async {
      when(
        () =>
            remote.getTopHeadlines(category: 'general', page: 2, pageSize: 20),
      ).thenAnswer((_) async => [_articleModel('3')]);

      await repo.getTopHeadlines(category: 'general', page: 2);

      verifyNever(() => local.cacheArticles(any(), any()));
    });

    test('returns ServerFailure on 500 error', () async {
      when(
        () => remote.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(const ServerException(message: 'err', statusCode: 500));

      final result = await repo.getTopHeadlines(category: 'general');

      expect(result.failure, isA<ServerFailure>());
    });

    test('returns UnauthorizedFailure on 401', () async {
      when(
        () => remote.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(const UnauthorizedException());

      final result = await repo.getTopHeadlines(category: 'general');

      expect(result.failure, isA<UnauthorizedFailure>());
    });

    test('overlays bookmark state from local storage', () async {
      when(
        () =>
            remote.getTopHeadlines(category: 'general', page: 1, pageSize: 20),
      ).thenAnswer((_) async => [_articleModel('1')]);
      when(() => local.cacheArticles(any(), any())).thenAnswer((_) async {});
      // Mark this article as bookmarked
      when(() => local.isBookmarked('https://example.com/1')).thenReturn(true);

      final result = await repo.getTopHeadlines(category: 'general');
      expect(result.data!.first.isBookmarked, isTrue);
    });
  });

  group('getTopHeadlines() — offline', () {
    setUp(() {
      when(() => connectivity.isConnected).thenAnswer((_) async => false);
    });

    test('returns cached articles when offline', () async {
      when(
        () => local.getCachedArticles('general'),
      ).thenReturn([_hiveModel('1'), _hiveModel('2')]);

      final result = await repo.getTopHeadlines(category: 'general');

      expect(result.failure, isNull);
      expect(result.data, hasLength(2));
    });

    test('returns NetworkFailure when offline and cache empty', () async {
      when(() => local.getCachedArticles('general')).thenReturn([]);

      final result = await repo.getTopHeadlines(category: 'general');

      expect(result.failure, isA<NetworkFailure>());
    });
  });

  group('searchArticles()', () {
    test('returns results from remote', () async {
      when(
        () => remote.searchArticles(query: 'flutter', page: 1, pageSize: 20),
      ).thenAnswer((_) async => [_articleModel('x')]);

      final result = await repo.searchArticles(query: 'flutter');
      expect(result.data, hasLength(1));
    });

    test('wraps NetworkException in NetworkFailure', () async {
      when(
        () => remote.searchArticles(
          query: any(named: 'query'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(const NetworkException(message: 'timeout'));

      final result = await repo.searchArticles(query: 'flutter');
      expect(result.failure, isA<NetworkFailure>());
    });
  });

  group('addBookmark() / removeBookmark() / getBookmarks()', () {
    final article = ArticleEntity(
      id: 'b1',
      title: 'B',
      description: null,
      content: null,
      urlToImage: null,
      url: 'b1',
      author: null,
      sourceName: 'S',
      publishedAt: DateTime(2024),
      readTime: '1 min read',
    );

    test('addBookmark calls local.saveBookmark', () async {
      when(() => local.saveBookmark(any())).thenAnswer((_) async {});

      final result = await repo.addBookmark(article);
      expect(result.failure, isNull);
      verify(() => local.saveBookmark(any())).called(1);
    });

    test('removeBookmark calls local.deleteBookmark', () async {
      when(() => local.deleteBookmark('b1')).thenAnswer((_) async {});

      final result = await repo.removeBookmark('b1');
      expect(result.failure, isNull);
    });

    test('getBookmarks maps hive models to entities', () async {
      when(() => local.getBookmarks()).thenReturn([_hiveModel('bm1')]);

      final result = await repo.getBookmarks();
      expect(result.data, hasLength(1));
      expect(result.data!.first.id, 'https://example.com/bm1');
    });
  });
}
