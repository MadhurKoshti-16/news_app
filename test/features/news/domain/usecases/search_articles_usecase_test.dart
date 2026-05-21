// test/features/news/domain/usecases/search_articles_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/article_entity.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/search_articles_usecase.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late MockNewsRepository mockRepo;
  late SearchArticlesUseCase useCase;

  setUp(() {
    mockRepo = MockNewsRepository();
    useCase = SearchArticlesUseCase(mockRepo);
  });

  group('SearchArticlesUseCase', () {
    test('returns empty list when repo returns empty', () async {
      final List<ArticleEntity> articles = [];
      when(
        () => mockRepo.searchArticles(
          query: any(named: 'query'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: null, data: articles));

      final result = await useCase(query: 'flutter');
      expect(result.failure, isNull);
      expect(result.data, isEmpty);
    });

    test('returns failure on network error', () async {
      const failure = NetworkFailure(message: 'timeout');
      when(
        () => mockRepo.searchArticles(
          query: any(named: 'query'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: failure, data: null));

      final result = await useCase(query: 'flutter');
      expect(result.failure, isA<NetworkFailure>());
    });

    test('passes query to repository unchanged', () async {
      const q = 'Dart programming';
      final List<ArticleEntity> articles = [];
      when(
        () => mockRepo.searchArticles(query: q, page: 1, pageSize: 20),
      ).thenAnswer((_) async => (failure: null, data: articles));

      await useCase(query: q);

      verify(
        () => mockRepo.searchArticles(query: q, page: 1, pageSize: 20),
      ).called(1);
    });
  });
}
