// test/features/news/presentation/providers/bookmark_provider_test.dart
//
// Unit tests for BookmarkNotifier — optimistic updates and rollback.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/article_entity.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/bookmark_usecases.dart';
import 'package:news_app/features/news/presentation/providers/bookmark_provider.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

ArticleEntity _article(String id) => ArticleEntity(
  id: id,
  title: 'A',
  description: null,
  content: null,
  urlToImage: null,
  url: id,
  author: null,
  sourceName: 'S',
  publishedAt: DateTime(2024),
  readTime: '1 min read',
);

void main() {
  late MockNewsRepository mockRepo;

  setUp(() => mockRepo = MockNewsRepository());

  BookmarkNotifier buildNotifier(List<ArticleEntity> initialBookmarks) {
    when(
      () => mockRepo.getBookmarks(),
    ).thenAnswer((_) async => (failure: null, data: initialBookmarks));
    when(
      () => mockRepo.addBookmark(any()),
    ).thenAnswer((_) async => (failure: null, data: null));
    when(
      () => mockRepo.removeBookmark(any()),
    ).thenAnswer((_) async => (failure: null, data: null));

    return BookmarkNotifier(
      GetBookmarksUseCase(mockRepo),
      AddBookmarkUseCase(mockRepo),
      RemoveBookmarkUseCase(mockRepo),
    );
  }

  group('BookmarkNotifier', () {
    test('loads bookmarks on construction', () async {
      final articles = [_article('b1'), _article('b2')];
      final notifier = buildNotifier(articles);
      await Future.delayed(Duration.zero);

      final s = notifier.state as BookmarkStateSuccess;
      expect(s.articles, hasLength(2));
    });

    test('toggleBookmark adds article optimistically', () async {
      final notifier = buildNotifier([]);
      await Future.delayed(Duration.zero);

      final article = _article('new');
      notifier.toggleBookmark(article);

      // Optimistic: check immediately (before async DB write)
      final s = notifier.state as BookmarkStateSuccess;
      expect(s.articles.any((a) => a.id == 'new'), isTrue);
    });

    test('toggleBookmark removes existing article optimistically', () async {
      final existing = _article('b1');
      final notifier = buildNotifier([existing]);
      await Future.delayed(Duration.zero);

      notifier.toggleBookmark(existing);

      final s = notifier.state as BookmarkStateSuccess;
      expect(s.articles.any((a) => a.id == 'b1'), isFalse);
    });

    test('toggleBookmark rolls back add if DB write fails', () async {
      when(
        () => mockRepo.getBookmarks(),
      ).thenAnswer((_) async => (failure: null, data: <ArticleEntity>[]));
      when(() => mockRepo.addBookmark(any())).thenAnswer(
        (_) async =>
            (failure: const CacheFailure(message: 'disk full'), data: null),
      );
      when(
        () => mockRepo.removeBookmark(any()),
      ).thenAnswer((_) async => (failure: null, data: null));

      final notifier = BookmarkNotifier(
        GetBookmarksUseCase(mockRepo),
        AddBookmarkUseCase(mockRepo),
        RemoveBookmarkUseCase(mockRepo),
      );
      await Future.delayed(Duration.zero);

      await notifier.toggleBookmark(_article('rollback'));

      // After rollback article should NOT be in bookmarks
      final s = notifier.state as BookmarkStateSuccess;
      expect(s.articles.any((a) => a.id == 'rollback'), isFalse);
    });

    test('isBookmarked returns correct value', () async {
      final notifier = buildNotifier([_article('yes')]);
      await Future.delayed(Duration.zero);

      expect(notifier.isBookmarked('yes'), isTrue);
      expect(notifier.isBookmarked('no'), isFalse);
    });
  });
}
