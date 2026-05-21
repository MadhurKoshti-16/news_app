import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/article_entity.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/get_top_headlines_usecase.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

ArticleEntity _makeArticle({String id = 'a1'}) => ArticleEntity(
  id: id,
  title: 'Test Article',
  description: 'description',
  content: 'content',
  urlToImage: null,
  url: 'https://example.com/$id',
  author: 'Author',
  sourceName: 'Test Source',
  publishedAt: DateTime(2024, 1, 1),
  readTime: '1 min read',
);

void main() {
  late MockNewsRepository mockRepo;
  late GetTopHeadlinesUseCase useCase;

  setUp(() {
    mockRepo = MockNewsRepository();
    useCase = GetTopHeadlinesUseCase(mockRepo);
  });

  group('GetTopHeadlinesUseCase', () {
    test('returns article list on success', () async {
      final articles = [_makeArticle(), _makeArticle(id: 'a2')];
      when(
        () => mockRepo.getTopHeadlines(
          category: 'general',
          page: 1,
          pageSize: 20,
        ),
      ).thenAnswer((_) async => (failure: null, data: articles));

      final result = await useCase(category: 'general');

      expect(result.failure, isNull);
      expect(result.data, equals(articles));
    });

    test('returns failure when repository fails', () async {
      const failure = NetworkFailure(message: 'no connection');
      when(
        () => mockRepo.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: failure, data: null));

      final result = await useCase(category: 'business');

      expect(result.failure, isA<NetworkFailure>());
      expect(result.data, isNull);
    });

    test('passes through page and pageSize parameters', () async {
      final List<ArticleEntity> articles = [];
      when(
        () =>
            mockRepo.getTopHeadlines(category: 'sports', page: 2, pageSize: 10),
      ).thenAnswer((_) async => (failure: null, data: articles));

      await useCase(category: 'sports', page: 2, pageSize: 10);

      verify(
        () =>
            mockRepo.getTopHeadlines(category: 'sports', page: 2, pageSize: 10),
      ).called(1);
    });
  });
}
