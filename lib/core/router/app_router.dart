import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/news/domain/entities/article_entity.dart';
import '../../features/news/presentation/screens/article_detail_screen.dart';
import '../../features/news/presentation/screens/bookmarks_screen.dart';
import '../../features/news/presentation/screens/home_screen.dart';
import '../../features/news/presentation/screens/search_screen.dart';
import '../../features/news/presentation/screens/splash_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String articleDetail = '/article';
  static const String bookmarks = '/bookmarks';
  static const String search = '/search';
  static const String settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.articleDetail,
        builder: (context, state) {
          final article = state.extra as ArticleEntity;
          return ArticleDetailScreen(article: article);
        },
      ),
      GoRoute(
        path: AppRoutes.bookmarks,
        builder: (_, _) => const BookmarksScreen(),
      ),
      GoRoute(path: AppRoutes.search, builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
