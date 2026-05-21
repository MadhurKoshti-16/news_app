// test/features/news/presentation/providers/search_provider_test.dart
//
// Unit tests for SearchNotifier.
// Covers: all 6 state transitions, debounce guard, min-char guard.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/core/error/failures.dart';
import 'package:news_app/features/news/domain/entities/article_entity.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/search_articles_usecase.dart';
import 'package:news_app/features/news/presentation/providers/search_provider.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

ArticleEntity _article(String id) => ArticleEntity(
  id: id,
  title: 'Article $id',
  description: null,
  content: null,
  urlToImage: null,
  url: id,
  author: null,
  sourceName: 'Source',
  publishedAt: DateTime(2024),
  readTime: '1 min read',
);

void main() {
  late MockNewsRepository mockRepo;
  late SearchArticlesUseCase useCase;

  setUp(() {
    mockRepo = MockNewsRepository();
    useCase = SearchArticlesUseCase(mockRepo);
  });

  group('SearchNotifier — state transitions', () {
    test('T1: stays idle when query < 3 chars', () {
      final notifier = SearchNotifier(useCase);

      notifier.onQueryChanged('ab'); // 2 chars — below threshold

      expect(notifier.state, isA<SearchStateIdle>());
      verifyNever(
        () => mockRepo.searchArticles(
          query: any(named: 'query'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      );
    });

    test('T2: transitions to Debouncing on valid query before timer fires', () {
      final notifier = SearchNotifier(useCase);

      notifier.onQueryChanged('flutter'); // 7 chars — valid

      // Check immediately before the 300 ms timer fires
      expect(notifier.state, isA<SearchStateDebouncing>());
      final s = notifier.state as SearchStateDebouncing;
      expect(s.query, 'flutter');
    });

    test('T3: debouncing → loading → success after debounce delay', () async {
      final articles = [_article('r1'), _article('r2')];
      when(
        () => mockRepo.searchArticles(query: 'flutter', page: 1, pageSize: 20),
      ).thenAnswer((_) async => (failure: null, data: articles));

      final notifier = SearchNotifier(useCase);
      notifier.onQueryChanged('flutter');

      expect(notifier.state, isA<SearchStateDebouncing>());

      // Advance past the 300 ms debounce window
      await Future.delayed(const Duration(milliseconds: 350));

      expect(notifier.state, isA<SearchStateSuccess>());
      final s = notifier.state as SearchStateSuccess;
      expect(s.results, hasLength(2));
      expect(s.query, 'flutter');
    });

    test('T4: transitions to Empty when search returns no results', () async {
      when(
        () => mockRepo.searchArticles(
          query: any(named: 'query'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: null, data: <ArticleEntity>[]));

      final notifier = SearchNotifier(useCase);
      notifier.onQueryChanged('xyzxyzxyz');

      await Future.delayed(const Duration(milliseconds: 350));

      expect(notifier.state, isA<SearchStateEmpty>());
      expect((notifier.state as SearchStateEmpty).query, 'xyzxyzxyz');
    });

    test('T5: transitions to Error on network failure', () async {
      when(
        () => mockRepo.searchArticles(
          query: any(named: 'query'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async =>
            (failure: const NetworkFailure(message: 'offline'), data: null),
      );

      final notifier = SearchNotifier(useCase);
      notifier.onQueryChanged('dart lang');

      await Future.delayed(const Duration(milliseconds: 350));

      expect(notifier.state, isA<SearchStateError>());
      expect(
        (notifier.state as SearchStateError).failure,
        isA<NetworkFailure>(),
      );
    });

    test('T6: clearSearch resets to Idle from any state', () async {
      final notifier = SearchNotifier(useCase);
      notifier.onQueryChanged('some query'); // → Debouncing

      notifier.clearSearch(); // → Idle

      expect(notifier.state, isA<SearchStateIdle>());
    });
  });

  group('SearchNotifier — debounce behaviour', () {
    test('rapid typing triggers only ONE API call', () async {
      when(
        () => mockRepo.searchArticles(
          query: any(named: 'query'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => (failure: null, data: <ArticleEntity>[]));

      final notifier = SearchNotifier(useCase);

      // Simulate fast typing (each call resets the 300 ms timer)
      notifier.onQueryChanged('flu');
      notifier.onQueryChanged('flut');
      notifier.onQueryChanged('flutt');
      notifier.onQueryChanged('flutte');
      notifier.onQueryChanged('flutter');

      // Wait for ONE debounce window
      await Future.delayed(const Duration(milliseconds: 400));

      // Only the last query should have triggered a real API call
      verify(
        () => mockRepo.searchArticles(query: 'flutter', page: 1, pageSize: 20),
      ).called(1);

      // Intermediate queries must NOT have triggered calls
      verifyNever(
        () => mockRepo.searchArticles(
          query: 'flu',
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      );
    });

    test(
      'query shorter than 3 chars after typing valid query → resets to idle',
      () async {
        final notifier = SearchNotifier(useCase);
        notifier.onQueryChanged('hello'); // valid
        notifier.onQueryChanged('hi'); // too short — should cancel timer

        expect(notifier.state, isA<SearchStateIdle>());

        // No API call should fire even after the debounce window
        await Future.delayed(const Duration(milliseconds: 400));
        verifyNever(
          () => mockRepo.searchArticles(
            query: any(named: 'query'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        );
      },
    );
  });
}
