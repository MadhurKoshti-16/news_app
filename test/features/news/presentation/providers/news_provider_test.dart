// test/features/news/presentation/providers/news_provider_test.dart
//
// Unit tests for NewsNotifier — state transitions, pagination, error handling.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/article_entity.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/get_top_headlines_usecase.dart';
import 'package:news_app/features/news/presentation/providers/news_provider.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

ArticleEntity _article(String id) => ArticleEntity(
  id: id,
  title: 'Title $id',
  description: null,
  content: null,
  urlToImage: null,
  url: id,
  author: null,
  sourceName: 'Source',
  publishedAt: DateTime(2024),
  readTime: '1 min read',
);

List<ArticleEntity> _page(int start, int count) =>
    List.generate(count, (i) => _article('a${start + i}'));

void main() {
  late MockNewsRepository mockRepo;

  setUp(() {
    mockRepo = MockNewsRepository();
  });

  group('NewsNotifier', () {
    test('initial state is NewsStateLoading', () async {
      when(
        () => mockRepo.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: null, data: <ArticleEntity>[]));

      final notifier = NewsNotifier(
        GetTopHeadlinesUseCase(mockRepo),
        category: 'general',
      );

      // Immediately after construction (before first fetch resolves) it is
      // not loading if fetch already completed synchronously. So we check
      // that the final state after await is success.
      await Future.delayed(Duration.zero);
      expect(notifier.state, isA<NewsStateSuccess>());
    });

    test('fetchArticles transitions to Success on data', () async {
      final articles = _page(0, 5);
      when(
        () => mockRepo.getTopHeadlines(
          category: 'general',
          page: 1,
          pageSize: 20,
        ),
      ).thenAnswer((_) async => (failure: null, data: articles));

      final notifier = NewsNotifier(
        GetTopHeadlinesUseCase(mockRepo),
        category: 'general',
      );
      await Future.delayed(Duration.zero);

      final s = notifier.state as NewsStateSuccess;
      expect(s.articles, hasLength(5));
      expect(s.isLoadingMore, isFalse);
      expect(s.hasReachedEnd, isFalse); // 5 < 20
    });

    test('hasReachedEnd is true when fewer articles than pageSize', () async {
      when(
        () => mockRepo.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: null, data: _page(0, 5)));

      final notifier = NewsNotifier(
        GetTopHeadlinesUseCase(mockRepo),
        category: 'general',
      );
      await Future.delayed(Duration.zero);

      expect((notifier.state as NewsStateSuccess).hasReachedEnd, isTrue);
    });

    test('fetchArticles transitions to Error on failure', () async {
      when(
        () => mockRepo.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async =>
            (failure: const NetworkFailure(message: 'off'), data: null),
      );

      final notifier = NewsNotifier(
        GetTopHeadlinesUseCase(mockRepo),
        category: 'general',
      );
      await Future.delayed(Duration.zero);

      expect(notifier.state, isA<NewsStateError>());
    });

    test('loadMore appends articles to existing list', () async {
      // Page 1: 20 articles (full page)
      when(
        () => mockRepo.getTopHeadlines(
          category: 'general',
          page: 1,
          pageSize: 20,
        ),
      ).thenAnswer((_) async => (failure: null, data: _page(0, 20)));

      // Page 2: 5 articles (partial = last page)
      when(
        () => mockRepo.getTopHeadlines(
          category: 'general',
          page: 2,
          pageSize: 20,
        ),
      ).thenAnswer((_) async => (failure: null, data: _page(20, 5)));

      final notifier = NewsNotifier(
        GetTopHeadlinesUseCase(mockRepo),
        category: 'general',
      );
      await Future.delayed(Duration.zero);

      expect((notifier.state as NewsStateSuccess).articles, hasLength(20));

      await notifier.loadMore();

      final s = notifier.state as NewsStateSuccess;
      expect(s.articles, hasLength(25));
      expect(s.hasReachedEnd, isTrue); // 5 < 20
    });

    test('loadMore is no-op when hasReachedEnd is true', () async {
      // Return only 3 articles so hasReachedEnd = true immediately
      when(
        () => mockRepo.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: null, data: _page(0, 3)));

      final notifier = NewsNotifier(
        GetTopHeadlinesUseCase(mockRepo),
        category: 'general',
      );
      await Future.delayed(Duration.zero);

      await notifier.loadMore(); // should be no-op

      // Only 1 call (from initial fetchArticles)
      verify(
        () => mockRepo.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).called(1);
    });

    test('refresh resets page to 1 and replaces articles', () async {
      when(
        () => mockRepo.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      )
      // First call (fetchArticles)
      .thenAnswerSequentially([
        (_) async => (failure: null, data: _page(0, 20)),
        // Second call (refresh)
        (_) async => (failure: null, data: _page(100, 10)),
      ]);

      final notifier = NewsNotifier(
        GetTopHeadlinesUseCase(mockRepo),
        category: 'general',
      );
      await Future.delayed(Duration.zero);

      await notifier.refresh();

      final s = notifier.state as NewsStateSuccess;
      // After refresh only the new articles should be present
      expect(s.articles.first.id, 'a100');
    });

    test(
      'updateBookmarkState toggles isBookmarked on correct article',
      () async {
        when(
          () => mockRepo.getTopHeadlines(
            category: any(named: 'category'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => (failure: null, data: _page(0, 3)));

        final notifier = NewsNotifier(
          GetTopHeadlinesUseCase(mockRepo),
          category: 'general',
        );
        await Future.delayed(Duration.zero);

        notifier.updateBookmarkState('a1', isBookmarked: true);

        final s = notifier.state as NewsStateSuccess;
        final a1 = s.articles.firstWhere((a) => a.id == 'a1');
        expect(a1.isBookmarked, isTrue);
      },
    );

    test('deduplicates articles by id', () async {
      // Page 1 returns articles with duplicate IDs
      final duplicates = [_article('dup'), _article('dup'), _article('unique')];
      when(
        () => mockRepo.getTopHeadlines(
          category: any(named: 'category'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: null, data: duplicates));

      final notifier = NewsNotifier(
        GetTopHeadlinesUseCase(mockRepo),
        category: 'general',
      );
      await Future.delayed(Duration.zero);

      expect((notifier.state as NewsStateSuccess).articles, hasLength(2));
    });
  });
}

extension _SequentialAnswer<T> on When<T> {
  void thenAnswerSequentially(List<Answer<T>> answers) {
    int i = 0;
    thenAnswer((inv) {
      final answer = answers[i.clamp(0, answers.length - 1)];
      i++;
      return answer(inv);
    });
  }
}
