import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/core/error/failures.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/news_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: switch (state) {
        BookmarkStateLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        BookmarkStateError(:final failure) => Center(
          child: Text(failure.userMessage),
        ),
        BookmarkStateSuccess(:final articles) =>
          articles.isEmpty
              ? const _EmptyBookmarks()
              : _BookmarkList(articles: articles),

        BookmarkState() => throw UnimplementedError(),
      },
    );
  }
}

class _BookmarkList extends StatelessWidget {
  const _BookmarkList({required this.articles});
  final List<ArticleEntity> articles;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (_, i) => _SwipeableCard(article: articles[i]),
    );
  }
}

class _SwipeableCard extends ConsumerWidget {
  const _SwipeableCard({required this.article});
  final ArticleEntity article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(article.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        ref.read(bookmarkNotifierProvider.notifier).toggleBookmark(article);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: const Text('Bookmark removed')));
        return false; // state already updated
      },
      child: NewsCard(
        key: ValueKey('card_${article.id}'),
        article: article.copyWith(isBookmarked: true),
        onTap: () => context.push(AppRoutes.articleDetail, extra: article),
        showBookmarkButton: false,
      ),
    );
  }
}

class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon on any article\nto save it for later.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
