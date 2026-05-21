// test/features/news/presentation/widgets/news_card_test.dart
//
// Widget tests for NewsCard:
//  1. Displays title text correctly
//  2. Shows image placeholder when urlToImage is null
//  3. Shows read-time badge
//  4. Shows bookmark button by default / hidden when showBookmarkButton=false
//  5. RepaintBoundary is present in the widget tree
//  6. onTap callback fires when tapped

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/news/presentation/providers/bookmark_provider.dart';
import 'package:news_app/features/news/presentation/widgets/news_card.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late TestBookmarkNotifier bookmarkNotifier;

  setUp(() {
    bookmarkNotifier = TestBookmarkNotifier();
  });

  /// Builds [NewsCard] inside a real ProviderScope with the fake bookmark notifier.
  Widget buildCard({
    String title = 'Test Article Title',
    String? urlToImage,
    String readTime = '3 min read',
    bool isBookmarked = false,
    bool showBookmarkButton = true,
    VoidCallback? onTap,
  }) {
    final article = fakeArticle(
      title: title,
      urlToImage: urlToImage,
      readTime: readTime,
      isBookmarked: isBookmarked,
    );

    return ProviderScope(
      overrides: [
        bookmarkNotifierProvider.overrideWith((ref) => bookmarkNotifier),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NewsCard(
              article: article,
              onTap: onTap ?? () {},
              showBookmarkButton: showBookmarkButton,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('displays article title', (tester) async {
    await tester.pumpWidget(buildCard(title: 'Breaking News Today'));

    expect(find.text('Breaking News Today'), findsOneWidget);
  });

  testWidgets('shows newspaper icon placeholder when urlToImage is null', (
    tester,
  ) async {
    await tester.pumpWidget(buildCard(urlToImage: null));

    // When there's no URL the placeholder renders a newspaper icon
    expect(find.byIcon(Icons.newspaper), findsOneWidget);
  });

  testWidgets('shows read-time badge with correct text', (tester) async {
    await tester.pumpWidget(buildCard(readTime: '5 min read'));

    expect(find.text('5 min read'), findsOneWidget);
  });

  testWidgets('shows bookmark button when showBookmarkButton is true', (
    tester,
  ) async {
    await tester.pumpWidget(buildCard(showBookmarkButton: true));

    expect(find.byType(BookmarkButton), findsOneWidget);
  });

  testWidgets('hides bookmark button when showBookmarkButton is false', (
    tester,
  ) async {
    await tester.pumpWidget(buildCard(showBookmarkButton: false));

    expect(find.byType(BookmarkButton), findsNothing);
  });

  testWidgets('is wrapped in RepaintBoundary', (tester) async {
    await tester.pumpWidget(buildCard());

    // RepaintBoundary should be an ancestor of the Card
    expect(find.byType(RepaintBoundary), findsWidgets);
    // Specifically, NewsCard itself renders a RepaintBoundary as its root
    final newsCard = find.byType(NewsCard);
    expect(newsCard, findsOneWidget);

    // Walk the widget tree from NewsCard and confirm RepaintBoundary is direct child
    final repaintFinder = find.descendant(
      of: newsCard,
      matching: find.byType(RepaintBoundary),
    );
    expect(repaintFinder, findsOneWidget);
  });

  testWidgets('calls onTap when card is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(buildCard(onTap: () => tapped = true));

    // Tap the InkWell inside the card (find by type Card then tap)
    await tester.tap(find.byType(InkWell).first);
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('displays source name in uppercase', (tester) async {
    final article = fakeArticle(sourceName: 'BBC News');
    final notifier = TestBookmarkNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookmarkNotifierProvider.overrideWith((ref) => notifier)],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NewsCard(article: article, onTap: () {}),
            ),
          ),
        ),
      ),
    );

    // Source displayed as uppercase
    expect(find.text('BBC NEWS'), findsOneWidget);
  });
}
