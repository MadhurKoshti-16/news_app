import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/news/data/models/article_hive_model.dart';

/// Box that stores cached news articles per category.
const String kArticlesBoxName = 'articles_cache';

/// Box that stores user-bookmarked articles.
const String kBookmarksBoxName = 'bookmarks';

/// Box for app settings (theme, font size, etc.)
const String kSettingsBoxName = 'settings';

final hiveServiceProvider = Provider<HiveStorage>((ref) => HiveStorage());

class HiveStorage {
  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(ArticleHiveModelAdapter().typeId)) {
      Hive.registerAdapter(ArticleHiveModelAdapter());
    }

    // Open persistent boxes
    await Hive.openBox<ArticleHiveModel>(kArticlesBoxName);
    await Hive.openBox<ArticleHiveModel>(kBookmarksBoxName);
    await Hive.openBox<dynamic>(kSettingsBoxName);
  }

  Box<ArticleHiveModel> get articlesBox =>
      Hive.box<ArticleHiveModel>(kArticlesBoxName);

  Box<ArticleHiveModel> get bookmarksBox =>
      Hive.box<ArticleHiveModel>(kBookmarksBoxName);

  Box<dynamic> get settingsBox => Hive.box<dynamic>(kSettingsBoxName);
}
