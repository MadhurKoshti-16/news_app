import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/article_hive_model.dart';

final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>((ref) {
  return NewsLocalDataSourceImpl(ref.watch(hiveServiceProvider));
});

abstract interface class NewsLocalDataSource {
  /// Returns cached articles for a given [category]. Empty list if none.
  List<ArticleHiveModel> getCachedArticles(String category);

  /// Overwrites cached articles for [category].
  Future<void> cacheArticles(String category, List<ArticleHiveModel> articles);

  /// Returns all bookmarked articles.
  List<ArticleHiveModel> getBookmarks();

  /// Saves an article to bookmarks.
  Future<void> saveBookmark(ArticleHiveModel article);

  /// Removes an article from bookmarks by [articleId].
  Future<void> deleteBookmark(String articleId);

  /// Checks if [articleId] exists in bookmarks.
  bool isBookmarked(String articleId);

  /// Clears all cached (non-bookmark) articles.
  Future<void> clearCache();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  const NewsLocalDataSourceImpl(this._hiveService);

  final HiveStorage _hiveService;

  @override
  List<ArticleHiveModel> getCachedArticles(String category) {
    try {
      final box = _hiveService.articlesBox;
      return box.values
          .where(
            (a) =>
                a.id.startsWith('${category}_') ||
                box.keys.any((k) => k.toString().startsWith(category)),
          )
          .toList();
    } catch (e) {
      AppLogger.error('getCachedArticles failed', error: e, tag: 'LocalDS');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheArticles(
    String category,
    List<ArticleHiveModel> articles,
  ) async {
    try {
      final box = _hiveService.articlesBox;

      // Clear old cache for this category first
      final oldKeys = box.keys
          .where((k) => k.toString().startsWith(category))
          .toList();
      await box.deleteAll(oldKeys);

      // Write new entries
      final Map<String, ArticleHiveModel> entries = {};
      for (var i = 0; i < articles.length; i++) {
        entries['${category}_$i'] = articles[i];
      }
      await box.putAll(entries);
    } catch (e) {
      AppLogger.error('cacheArticles failed', error: e, tag: 'LocalDS');
      throw CacheException(message: e.toString());
    }
  }

  @override
  List<ArticleHiveModel> getBookmarks() {
    try {
      return _hiveService.bookmarksBox.values.toList()
        ..sort((a, b) => b.cachedAt.compareTo(a.cachedAt));
    } catch (e) {
      AppLogger.error('getBookmarks failed', error: e, tag: 'LocalDS');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> saveBookmark(ArticleHiveModel article) async {
    try {
      article.isBookmarked = true;
      await _hiveService.bookmarksBox.put(article.id, article);
    } catch (e) {
      AppLogger.error('saveBookmark failed', error: e, tag: 'LocalDS');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> deleteBookmark(String articleId) async {
    try {
      await _hiveService.bookmarksBox.delete(articleId);
    } catch (e) {
      AppLogger.error('deleteBookmark failed', error: e, tag: 'LocalDS');
      throw CacheException(message: e.toString());
    }
  }

  @override
  bool isBookmarked(String articleId) {
    return _hiveService.bookmarksBox.containsKey(articleId);
  }

  @override
  Future<void> clearCache() async {
    try {
      await _hiveService.articlesBox.clear();
    } catch (e) {
      AppLogger.error('clearCache failed', error: e, tag: 'LocalDS');
      throw CacheException(message: e.toString());
    }
  }
}
