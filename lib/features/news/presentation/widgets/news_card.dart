import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/network/news_image_cache_manager.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/bookmark_provider.dart';

class NewsCard extends ConsumerWidget {
  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.showBookmarkButton = true,
  });

  final ArticleEntity article;
  final VoidCallback onTap;
  final bool showBookmarkButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: _CardContent(
        article: article,
        onTap: onTap,
        showBookmarkButton: showBookmarkButton,
      ),
    );
  }
}

class _CardContent extends ConsumerWidget {
  const _CardContent({
    required this.article,
    required this.onTap,
    required this.showBookmarkButton,
  });

  final ArticleEntity article;
  final VoidCallback onTap;
  final bool showBookmarkButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final theme = Theme.of(context);

    final state = ref.watch(bookmarkNotifierProvider);
    final isBookmarked = state is BookmarkStateSuccess
        ? state.articles.any((a) => a.id == article.id)
        : article.isBookmarked;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ext.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ArticleImage(urlToImage: article.urlToImage),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.sourceName.toUpperCase(),
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: ext.brandPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(article.publishedAt),
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Text(
                    article.title,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ext.brandPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          article.readTime,
                          style: theme.textTheme.labelSmall!.copyWith(
                            color: ext.brandPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),

                      if (showBookmarkButton)
                        BookmarkButton(
                          article: article,
                          isBookmarked: isBookmarked,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    return DateFormat('MMM d').format(date);
  }
}

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({this.urlToImage});

  final String? urlToImage;

  @override
  Widget build(BuildContext context) {
    if (urlToImage == null || urlToImage!.isEmpty) {
      return _placeholder();
    }

    return CachedNetworkImage(
      imageUrl: urlToImage!,
      cacheManager: NewsImageCacheManager(), // custom 7-day TTL manager
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, _) => _shimmerPlaceholder(context),
      errorWidget: (_, _, _) => _placeholder(),
    );
  }

  Widget _shimmerPlaceholder(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Shimmer.fromColors(
      baseColor: ext.shimmerBase,
      highlightColor: ext.shimmerHighlight,
      child: Container(height: 180, color: Colors.white),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.newspaper, size: 48, color: Colors.grey),
      ),
    );
  }
}

class BookmarkButton extends ConsumerWidget {
  const BookmarkButton({
    super.key,
    required this.article,
    required this.isBookmarked,
  });

  final ArticleEntity article;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return IconButton(
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: isBookmarked ? ext.brandPrimary : null,
      ),
      tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark',
      onPressed: () {
        ref.read(bookmarkNotifierProvider.notifier).toggleBookmark(article);
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
