import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app/core/error/failures.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/news_provider.dart';
import '../widgets/animated_news_ticker.dart';
import '../widgets/news_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/shimmer_card.dart';

class _Category {
  const _Category({required this.id, required this.label});
  final String id;
  final String label;
}

const List<_Category> _categories = [
  _Category(id: 'general', label: 'Top'),
  _Category(id: 'business', label: 'Business'),
  _Category(id: 'sports', label: 'Sports'),
  _Category(id: 'technology', label: 'Tech'),
  _Category(id: 'health', label: 'Health'),
  _Category(id: 'science', label: 'Science'),
  _Category(id: 'entertainment', label: 'Entertainment'),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = _categories[_selectedIndex].id;
    final newsState = ref.watch(newsNotifierProvider(category));
    final isOnline = ref.watch(isOnlineProvider).valueOrNull ?? true;

    List<String> tickerHeadlines = [];
    if (newsState is NewsStateSuccess) {
      tickerHeadlines = newsState.articles
          .take(10)
          .map((a) => a.title)
          .toList();
    } else if (newsState is NewsStateRefreshing) {
      tickerHeadlines = newsState.articles
          .take(10)
          .map((a) => a.title)
          .toList();
    }

    ArticleEntity? topArticle;
    if (newsState is NewsStateSuccess && newsState.articles.isNotEmpty) {
      topArticle = newsState.articles.first;
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          _ParallaxSliverAppBar(topArticle: topArticle),
          if (tickerHeadlines.isNotEmpty)
            SliverToBoxAdapter(
              child: AnimatedNewsTicker(headlines: tickerHeadlines),
            ),
          if (!isOnline) const SliverToBoxAdapter(child: OfflineBanner()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryTabDelegate(
              tabController: _tabController,
              categories: _categories,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _categories.map((c) => _NewsFeed(category: c.id)).toList(),
        ),
      ),
    );
  }
}

class _ParallaxSliverAppBar extends StatelessWidget {
  const _ParallaxSliverAppBar({this.topArticle});
  final ArticleEntity? topArticle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      stretch: true,
      title: const Text('NewsReader'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push(AppRoutes.search),
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () => context.push(AppRoutes.bookmarks),
          tooltip: 'Bookmarks',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(AppRoutes.settings),
          tooltip: 'Settings',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: topArticle?.urlToImage != null
            ? _HeroImage(imageUrl: topArticle!.urlToImage!)
            : _GradientPlaceholder(),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _GradientPlaceholder(),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }
}

class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  _CategoryTabDelegate({required this.tabController, required this.categories});
  final TabController tabController;
  final List<_Category> categories;

  late final TabBar _tabBar = TabBar(
    controller: tabController,
    isScrollable: true,
    tabAlignment: TabAlignment.start,
    tabs: categories.map((c) => Tab(text: c.label)).toList(),
  );

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: shrinkOffset > 0 ? 2 : 0,
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: categories.map((c) => Tab(text: c.label)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryTabDelegate old) => false;
}

class _NewsFeed extends ConsumerStatefulWidget {
  const _NewsFeed({required this.category});
  final String category;

  @override
  ConsumerState<_NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends ConsumerState<_NewsFeed>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(newsNotifierProvider(widget.category));

    if (state is NewsStateLoading) {
      return const ShimmerNewsList();
    }

    if (state is NewsStateError) {
      return _ErrorView(
        message: state.failure.userMessage,
        onRetry: () => ref
            .read(newsNotifierProvider(widget.category).notifier)
            .fetchArticles(),
      );
    }

    final articles = state is NewsStateSuccess
        ? state.articles
        : (state as NewsStateRefreshing).articles;
    final isLoadingMore = state is NewsStateSuccess
        ? state.isLoadingMore
        : false;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 300) {
          ref.read(newsNotifierProvider(widget.category).notifier).loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(newsNotifierProvider(widget.category).notifier).refresh(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: articles.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == articles.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final article = articles[index];
            return NewsCard(
              key: ValueKey(article.id),
              article: article,
              onTap: () =>
                  context.push(AppRoutes.articleDetail, extra: article),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
