import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/news_image_cache_manager.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../settings/presentation/provides/settings_provider.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/news_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final ArticleEntity article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final theme = Theme.of(context);

    final state = ref.watch(bookmarkNotifierProvider);
    final isBookmarked = state is BookmarkStateSuccess
        ? state.articles.any((a) => a.id == article.id)
        : article.isBookmarked;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Share',
                onPressed: () => Share.share(
                  // ShareParams(
                  '${article.title}\n\n${article.url}',
                    subject: article.title,
                  // ),
                ),
                // onPressed: () => SharePlus.instance.share(
                //   ShareParams(
                //     text: '${article.title}\n\n${article.url}',
                //     subject: article.title,
                //   ),
                // ),
              ),
              BookmarkButton(article: article, isBookmarked: isBookmarked),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: article.urlToImage != null
                  ? CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      cacheManager: NewsImageCacheManager(),
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        color: theme.colorScheme.primary,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Container(color: ext.brandPrimary),
              stretchModes: const [StretchMode.zoomBackground],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        article.sourceName.toUpperCase(),
                        style: theme.textTheme.labelSmall!.copyWith(
                          color: ext.brandPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
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
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (article.author != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            article.author!,
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'MMMM d, yyyy',
                          ).format(article.publishedAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Divider(),
                  const SizedBox(height: 16),

                  if (article.description != null) ...[
                    Text(
                      article.description!,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    _cleanContent(article.content) ??
                        article.description ??
                        'Full article not available. Tap the link below to read more.',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      height: 1.7,
                      fontSize: settings.fontSize.toDouble(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Read Full Article'),
                      onPressed: () async {
                        final url = Uri.parse(article.url);

                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.inAppBrowserView,
                          browserConfiguration: const BrowserConfiguration(
                            showTitle: true,
                          ),
                        )) {
                          throw Exception('Could not launch $url');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// NewsAPI content often ends with "[+N chars]" — remove it.
  String? _cleanContent(String? content) {
    if (content == null) return null;
    return content.replaceAll(RegExp(r'\s*\[\+\d+ chars\]$'), '').trim();
  }
}
