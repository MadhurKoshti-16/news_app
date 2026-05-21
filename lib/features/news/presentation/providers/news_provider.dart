import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/usecases/get_top_headlines_usecase.dart';

abstract class NewsState {
  const NewsState();
}

class NewsStateLoading extends NewsState {
  const NewsStateLoading();
}

class NewsStateSuccess extends NewsState {
  const NewsStateSuccess({
    required this.articles,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.isOffline = false,
  });

  final List<ArticleEntity> articles;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  /// True when data came from cache (no internet).
  final bool isOffline;

  NewsStateSuccess copyWith({
    List<ArticleEntity>? articles,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? isOffline,
  }) {
    return NewsStateSuccess(
      articles: articles ?? this.articles,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class NewsStateError extends NewsState {
  const NewsStateError({required this.failure});
  final Failure failure;
}

class NewsStateRefreshing extends NewsState {
  const NewsStateRefreshing({required this.articles});
  final List<ArticleEntity> articles;
}

final getTopHeadlinesUseCaseProvider = Provider<GetTopHeadlinesUseCase>((ref) {
  return GetTopHeadlinesUseCase(ref.watch(newsRepositoryProvider));
});

final newsNotifierProvider =
    StateNotifierProvider.family<NewsNotifier, NewsState, String>(
      (ref, category) => NewsNotifier(
        ref.watch(getTopHeadlinesUseCaseProvider),
        category: category,
      ),
    );

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier(this._useCase, {required this.category})
    : super(const NewsStateLoading()) {
    fetchArticles();
  }

  final GetTopHeadlinesUseCase _useCase;
  final String category;

  int _currentPage = 1;
  static const int _pageSize = 20;

  /// Initial fetch / retry after error.
  Future<void> fetchArticles() async {
    state = const NewsStateLoading();
    _currentPage = 1;
    await _loadPage(page: 1);
  }

  /// Pull-to-refresh — keeps existing articles visible while fetching.
  Future<void> refresh() async {
    final current = _currentArticles;
    state = NewsStateRefreshing(articles: current);
    _currentPage = 1;
    await _loadPage(page: 1, existingArticles: []);
  }

  /// Infinite-scroll load-more.
  Future<void> loadMore() async {
    final s = state;
    if (s is! NewsStateSuccess) return;
    if (s.isLoadingMore || s.hasReachedEnd) return;

    // Show bottom loading indicator
    state = s.copyWith(isLoadingMore: true);
    _currentPage++;
    await _loadPage(page: _currentPage, existingArticles: s.articles);
  }

  void updateBookmarkState(String articleId, {required bool isBookmarked}) {
    final s = state;
    if (s is! NewsStateSuccess) return;
    state = s.copyWith(
      articles: s.articles.map((a) {
        return a.id == articleId ? a.copyWith(isBookmarked: isBookmarked) : a;
      }).toList(),
    );
  }

  List<ArticleEntity> get _currentArticles {
    final s = state;
    if (s is NewsStateSuccess) return s.articles;
    if (s is NewsStateRefreshing) return s.articles;
    return [];
  }

  Future<void> _loadPage({
    required int page,
    List<ArticleEntity> existingArticles = const [],
  }) async {
    final result = await _useCase(
      category: category,
      page: page,
      pageSize: _pageSize,
    );

    if (result.failure != null) {
      if (page > 1) {
        final s = state;
        if (s is NewsStateSuccess) {
          state = s.copyWith(isLoadingMore: false, hasReachedEnd: true);
        }
      } else {
        state = NewsStateError(failure: result.failure!);
      }
      return;
    }

    final newArticles = result.data ?? [];
    final combined = page == 1
        ? newArticles
        : [...existingArticles, ...newArticles];

    // Deduplicate by id (prevents duplicates on refresh race conditions)
    final seen = <String>{};
    final deduped = combined.where((a) => seen.add(a.id)).toList();

    state = NewsStateSuccess(
      articles: deduped,
      isLoadingMore: false,
      hasReachedEnd: newArticles.isEmpty,
      isOffline: result.failure is NetworkFailure,
    );
  }
}
