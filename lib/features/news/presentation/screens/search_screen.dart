import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when the screen opens
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    ref.read(searchNotifierProvider.notifier).clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Search news...',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchNotifierProvider.notifier).clearSearch();
                    },
                  )
                : null,
          ),
          onChanged: (query) {
            setState(() {}); // rebuild to show/hide clear button
            ref.read(searchNotifierProvider.notifier).onQueryChanged(query);
          },
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state is SearchStateIdle) {
      return const _IdleView();
    }
    if (state is SearchStateDebouncing || state is SearchStateLoading) {
      return const _SearchingIndicator();
    }
    if (state is SearchStateSuccess) {
      return _ResultsList(results: state.results, query: state.query);
    }
    if (state is SearchStateEmpty) {
      return _EmptyView(query: state.query);
    }
    if (state is SearchStateError) {
      return _ErrorView(message: (state).failure.userMessage);
    }
    return const SizedBox.shrink();
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 72,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Type at least 3 characters to search',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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

class _SearchingIndicator extends StatelessWidget {
  const _SearchingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No results for "$query"',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results, required this.query});

  final List<ArticleEntity> results;
  final String query;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final article = results[index];
        return _SearchResultTile(article: article, query: query);
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.article, required this.query});

  final ArticleEntity article;
  final String query;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: article.urlToImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.urlToImage!,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.newspaper, size: 72),
              ),
            )
          : const Icon(Icons.newspaper, size: 72),
      title: _HighlightedText(
        text: article.title,
        query: query,
        baseStyle: theme.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        highlightStyle: theme.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
          backgroundColor: ext.brandPrimary.withValues(alpha: 0.25),
          color: ext.brandPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          article.sourceName,
          style: theme.textTheme.labelSmall!.copyWith(color: ext.brandPrimary),
        ),
      ),
      onTap: () => context.push(AppRoutes.articleDetail, extra: article),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightStyle,
  });

  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: baseStyle);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    int matchIndex;

    while ((matchIndex = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (matchIndex > start) {
        spans.add(
          TextSpan(text: text.substring(start, matchIndex), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style: highlightStyle,
        ),
      );
      start = matchIndex + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }

    return RichText(
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: spans),
    );
  }
}
