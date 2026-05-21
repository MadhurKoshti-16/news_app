import '../entities/article_entity.dart';
import '../../../../core/error/failures.dart';

typedef NewsResult<T> = Future<({Failure? failure, T? data})>;

abstract interface class NewsRepository {
  NewsResult<List<ArticleEntity>> getTopHeadlines({
    required String category,
    int page = 1,
    int pageSize = 20,
  });

  /// Full-text search across all news articles.
  NewsResult<List<ArticleEntity>> searchArticles({
    required String query,
    int page = 1,
    int pageSize = 20,
  });

  /// Returns all bookmarked articles from local storage.
  NewsResult<List<ArticleEntity>> getBookmarks();

  /// Persists a bookmark to local storage.
  NewsResult<void> addBookmark(ArticleEntity article);

  /// Removes a bookmark from local storage.
  NewsResult<void> removeBookmark(String articleId);

  /// Returns whether an article with [articleId] is bookmarked.
  Future<bool> isBookmarked(String articleId);

  /// Clears all cached articles from local storage.
  NewsResult<void> clearCache();
}
