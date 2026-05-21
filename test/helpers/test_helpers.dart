import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app/features/news/domain/entities/article_entity.dart';
import 'package:news_app/features/news/domain/repositories/news_repository.dart';
import 'package:news_app/features/news/presentation/providers/bookmark_provider.dart';

ArticleEntity fakeArticle({
  String id = 'test-id',
  String title = 'Test Article Title',
  String? urlToImage,
  String readTime = '3 min read',
  bool isBookmarked = false,
  String sourceName = 'Test Source',
}) {
  return ArticleEntity(
    id: id,
    title: title,
    description: 'A test description for the article.',
    content: 'Full content of the article goes here. ' * 10,
    urlToImage: urlToImage,
    url: 'https://example.com/$id',
    author: 'Test Author',
    sourceName: sourceName,
    publishedAt: DateTime(2024, 6, 1),
    readTime: readTime,
    isBookmarked: isBookmarked,
  );
}

class MockNewsRepository extends Mock implements NewsRepository {}

class FakeBookmarkNotifier extends BookmarkNotifier {
  FakeBookmarkNotifier(
    super.getBookmarks,
    super.addBookmark,
    super.removeBookmark,
  );
}

/// A simple fake BookmarkNotifier that starts with a pre-set list of bookmarks.
class TestBookmarkNotifier extends StateNotifier<BookmarkState>
    implements BookmarkNotifier {
  TestBookmarkNotifier({List<ArticleEntity> bookmarks = const []})
    : super(BookmarkStateSuccess(articles: bookmarks));

  int toggleCallCount = 0;
  ArticleEntity? lastToggledArticle;

  @override
  Future<void> loadBookmarks() async {}

  @override
  Future<void> toggleBookmark(ArticleEntity article) async {
    toggleCallCount++;
    lastToggledArticle = article;

    final current = (state as BookmarkStateSuccess).articles;
    final isCurrentlyBookmarked = current.any((a) => a.id == article.id);

    if (isCurrentlyBookmarked) {
      state = BookmarkStateSuccess(
        articles: current.where((a) => a.id != article.id).toList(),
      );
    } else {
      state = BookmarkStateSuccess(
        articles: [article.copyWith(isBookmarked: true), ...current],
      );
    }
  }

  @override
  bool isBookmarked(String articleId) {
    final s = state;
    if (s is BookmarkStateSuccess) {
      return s.articles.any((a) => a.id == articleId);
    }
    return false;
  }
}

/// Wraps [child] in a [MaterialApp] + [ProviderScope] with optional overrides.
/// Use this in every widget test.
Widget testWidget(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}
