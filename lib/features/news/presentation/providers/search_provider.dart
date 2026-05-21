import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/usecases/search_articles_usecase.dart';

abstract class SearchState {
  const SearchState();
}

class SearchStateIdle extends SearchState {
  const SearchStateIdle();
}

class SearchStateDebouncing extends SearchState {
  const SearchStateDebouncing({required this.query});
  final String query;
}

class SearchStateLoading extends SearchState {
  const SearchStateLoading({required this.query});
  final String query;
}

class SearchStateSuccess extends SearchState {
  const SearchStateSuccess({required this.query, required this.results});
  final String query;
  final List<ArticleEntity> results;
}

class SearchStateEmpty extends SearchState {
  const SearchStateEmpty({required this.query});
  final String query;
}

class SearchStateError extends SearchState {
  const SearchStateError({required this.query, required this.failure});
  final String query;
  final Failure failure;
}

final searchArticlesUseCaseProvider = Provider<SearchArticlesUseCase>((ref) {
  return SearchArticlesUseCase(ref.watch(newsRepositoryProvider));
});

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
      (ref) => SearchNotifier(ref.watch(searchArticlesUseCaseProvider)),
    );

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._useCase) : super(const SearchStateIdle());

  final SearchArticlesUseCase _useCase;
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const int _minQueryLength = 3;

  Timer? _debounceTimer;

  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().length < _minQueryLength) {
      state = const SearchStateIdle();
      return;
    }

    state = SearchStateDebouncing(query: query);
    _debounceTimer = Timer(_debounceDuration, () => _search(query.trim()));
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = const SearchStateIdle();
  }

  Future<void> _search(String query) async {
    state = SearchStateLoading(query: query);
    final result = await _useCase(query: query);

    if (result.failure != null) {
      state = SearchStateError(query: query, failure: result.failure!);
      return;
    }

    final results = result.data ?? [];
    state = results.isEmpty
        ? SearchStateEmpty(query: query)
        : SearchStateSuccess(query: query, results: results);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
