import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class NewsImageCacheManager extends CacheManager with ImageCacheManager {
  static final NewsImageCacheManager _instance = NewsImageCacheManager._();
  factory NewsImageCacheManager() => _instance;

  /// Cache key — identifies this cache in the file system.
  static const String cacheKey = 'newsImageCache';

  /// Maximum age of a cached file: 7 days.
  static const Duration _stalePeriod = Duration(days: 7);

  static const int _maxNrOfCacheObjects = 100;

  NewsImageCacheManager._()
    : super(
        Config(
          cacheKey,
          stalePeriod: _stalePeriod,
          maxNrOfCacheObjects: _maxNrOfCacheObjects,
        ),
      );

  static bool isFileValid(FileInfo fileInfo) {
    return fileInfo.validTill.isAfter(DateTime.now());
  }
}
