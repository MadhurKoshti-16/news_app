import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/usecases/bookmark_usecases.dart';

abstract class BookmarkState {
  const BookmarkState();
}

class BookmarkStateLoading extends BookmarkState {
  const BookmarkStateLoading();
}

class BookmarkStateSuccess extends BookmarkState {
  const BookmarkStateSuccess({required this.articles});
  final List<ArticleEntity> articles;
}

class BookmarkStateError extends BookmarkState {
  const BookmarkStateError({required this.failure});
  final Failure failure;
}

final getBookmarksUseCaseProvider = Provider<GetBookmarksUseCase>((ref) {
  return GetBookmarksUseCase(ref.watch(newsRepositoryProvider));
});

final addBookmarkUseCaseProvider = Provider<AddBookmarkUseCase>((ref) {
  return AddBookmarkUseCase(ref.watch(newsRepositoryProvider));
});

final removeBookmarkUseCaseProvider = Provider<RemoveBookmarkUseCase>((ref) {
  return RemoveBookmarkUseCase(ref.watch(newsRepositoryProvider));
});

final bookmarkNotifierProvider =
    StateNotifierProvider<BookmarkNotifier, BookmarkState>(
      (ref) => BookmarkNotifier(
        ref.watch(getBookmarksUseCaseProvider),
        ref.watch(addBookmarkUseCaseProvider),
        ref.watch(removeBookmarkUseCaseProvider),
      ),
    );

class BookmarkNotifier extends StateNotifier<BookmarkState> {
  BookmarkNotifier(this._getBookmarks, this._addBookmark, this._removeBookmark)
    : super(const BookmarkStateLoading()) {
    loadBookmarks();
  }

  final GetBookmarksUseCase _getBookmarks;
  final AddBookmarkUseCase _addBookmark;
  final RemoveBookmarkUseCase _removeBookmark;

  Future<void> loadBookmarks() async {
    state = const BookmarkStateLoading();
    final result = await _getBookmarks();
    if (result.failure != null) {
      state = BookmarkStateError(failure: result.failure!);
    } else {
      state = BookmarkStateSuccess(articles: result.data ?? []);
    }
  }

  /// Optimistic toggle: update UI first, persist, rollback on failure.
  Future<void> toggleBookmark(ArticleEntity article) async {
    final s = state;
    final currentArticles = s is BookmarkStateSuccess
        ? s.articles
        : <ArticleEntity>[];

    final isCurrentlyBookmarked = currentArticles.any(
      (a) => a.id == article.id,
    );

    if (isCurrentlyBookmarked) {
      state = BookmarkStateSuccess(
        articles: currentArticles.where((a) => a.id != article.id).toList(),
      );
    } else {
      state = BookmarkStateSuccess(
        articles: [article.copyWith(isBookmarked: true), ...currentArticles],
      );
    }

    final result = isCurrentlyBookmarked
        ? await _removeBookmark(article.id)
        : await _addBookmark(article);

    if (result.failure != null) {
      state = BookmarkStateSuccess(articles: currentArticles);
    }
  }

  bool isBookmarked(String articleId) {
    final s = state;
    if (s is BookmarkStateSuccess) {
      return s.articles.any((a) => a.id == articleId);
    }
    return false;
  }
}
