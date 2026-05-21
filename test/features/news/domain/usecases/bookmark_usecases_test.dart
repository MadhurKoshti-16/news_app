import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/article_entity.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/bookmark_usecases.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

ArticleEntity _article() => ArticleEntity(
  id: 'id1',
  title: 'Title',
  description: null,
  content: null,
  urlToImage: null,
  url: 'https://example.com',
  author: null,
  sourceName: 'Source',
  publishedAt: DateTime(2024),
  readTime: '1 min read',
);

void main() {
  late MockNewsRepository mockRepo;

  setUp(() => mockRepo = MockNewsRepository());

  group('GetBookmarksUseCase', () {
    test('returns list on success', () async {
      final articles = [_article()];
      when(
        () => mockRepo.getBookmarks(),
      ).thenAnswer((_) async => (failure: null, data: articles));

      final result = await GetBookmarksUseCase(mockRepo)();
      expect(result.data, articles);
    });

    test('returns CacheFailure on error', () async {
      when(() => mockRepo.getBookmarks()).thenAnswer(
        (_) async => (failure: const CacheFailure(message: 'err'), data: null),
      );

      final result = await GetBookmarksUseCase(mockRepo)();
      expect(result.failure, isA<CacheFailure>());
    });
  });

  group('AddBookmarkUseCase', () {
    test('calls repository.addBookmark with correct article', () async {
      final article = _article();
      when(
        () => mockRepo.addBookmark(article),
      ).thenAnswer((_) async => (failure: null, data: null));

      await AddBookmarkUseCase(mockRepo)(article);

      verify(() => mockRepo.addBookmark(article)).called(1);
    });
  });

  group('RemoveBookmarkUseCase', () {
    test('calls repository.removeBookmark with correct id', () async {
      when(
        () => mockRepo.removeBookmark('id1'),
      ).thenAnswer((_) async => (failure: null, data: null));

      await RemoveBookmarkUseCase(mockRepo)('id1');

      verify(() => mockRepo.removeBookmark('id1')).called(1);
    });

    test('returns failure when remove fails', () async {
      when(() => mockRepo.removeBookmark(any())).thenAnswer(
        (_) async =>
            (failure: const CacheFailure(message: 'delete failed'), data: null),
      );

      final result = await RemoveBookmarkUseCase(mockRepo)('bad-id');
      expect(result.failure, isA<CacheFailure>());
    });
  });
}
