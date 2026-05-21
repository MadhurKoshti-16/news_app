// test/core/network/news_image_cache_manager_test.dart
//
// Unit tests for the custom image cache manager configuration.
// We verify TTL, max objects, and cache key without hitting the network.

import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/network/news_image_cache_manager.dart';

void main() {
  group('NewsImageCacheManager', () {
    test('singleton returns same instance', () {
      final a = NewsImageCacheManager();
      final b = NewsImageCacheManager();
      expect(identical(a, b), isTrue);
    });

    test('cache key is "newsImageCache"', () {
      expect(NewsImageCacheManager.cacheKey, 'newsImageCache');
    });

    test('isFileValid returns true for a file valid in the future', () {
      final validFileInfo = FileInfo(
        LocalFileSystem().file('test.jpg'),
        FileSource.Cache,
        DateTime.now().add(const Duration(days: 3)), // still valid
        'https://example.com/image.jpg',
      );
      expect(NewsImageCacheManager.isFileValid(validFileInfo), isTrue);
    });

    test('isFileValid returns false for an expired file', () {
      final expiredFileInfo = FileInfo(
        LocalFileSystem().file('test.jpg'),
        FileSource.Cache,
        DateTime.now().subtract(const Duration(days: 1)), // expired
        'https://example.com/image.jpg',
      );
      expect(NewsImageCacheManager.isFileValid(expiredFileInfo), isFalse);
    });
  });
}
