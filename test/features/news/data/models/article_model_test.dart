// test/features/news/data/models/article_model_test.dart
//
// Unit tests for ArticleModel JSON parsing and entity mapping.

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/features/news/data/models/article_model.dart';

void main() {
  group('ArticleModel', () {
    const validJson = {
      'source': {'id': 'bbc-news', 'name': 'BBC News'},
      'author': 'John Doe',
      'title': 'Test Headline',
      'description': 'A test description',
      'url': 'https://bbc.com/test',
      'urlToImage': 'https://bbc.com/image.jpg',
      'publishedAt': '2024-06-01T12:00:00Z',
      'content': 'Full article content here.',
    };

    test('fromJson parses all fields correctly', () {
      final model = ArticleModel.fromJson(validJson);

      expect(model.title, 'Test Headline');
      expect(model.author, 'John Doe');
      expect(model.description, 'A test description');
      expect(model.url, 'https://bbc.com/test');
      expect(model.urlToImage, 'https://bbc.com/image.jpg');
      expect(model.publishedAt, '2024-06-01T12:00:00Z');
      expect(model.content, 'Full article content here.');
      expect(model.source?.name, 'BBC News');
    });

    test('fromJson handles null fields gracefully', () {
      final model = ArticleModel.fromJson({
        'source': {'id': null, 'name': null},
        'author': null,
        'title': null,
        'url': null,
      });

      expect(model.title, isNull);
      expect(model.author, isNull);
    });

    test('toEntity() maps to ArticleEntity with correct id', () {
      final model = ArticleModel.fromJson(validJson);
      final entity = model.toEntity();

      expect(entity.id, 'https://bbc.com/test'); // URL as id
      expect(entity.title, 'Test Headline');
      expect(entity.sourceName, 'BBC News');
      expect(entity.isBookmarked, isFalse);
    });

    test('toEntity() computes readTime from content', () {
      final model = ArticleModel.fromJson(validJson);
      final entity = model.toEntity();
      expect(entity.readTime, endsWith('min read'));
    });

    test('toEntity() uses "No Title" when title is null', () {
      final model = ArticleModel.fromJson({...validJson, 'title': null});
      final entity = model.toEntity();
      expect(entity.title, 'No Title');
    });

    test(
      'toEntity() falls back to "Unknown" source name when source is null',
      () {
        final model = ArticleModel.fromJson({...validJson, 'source': null});
        final entity = model.toEntity();
        expect(entity.sourceName, 'Unknown');
      },
    );

    test('toEntity() handles malformed publishedAt gracefully', () {
      final model = ArticleModel.fromJson({
        ...validJson,
        'publishedAt': 'not-a-date',
      });
      // Should not throw; falls back to DateTime.now()
      expect(() => model.toEntity(), returnsNormally);
    });
  });

  group('ArticleSourceModel', () {
    test('fromJson parses id and name', () {
      final source = ArticleSourceModel.fromJson({'id': 'cnn', 'name': 'CNN'});
      expect(source.id, 'cnn');
      expect(source.name, 'CNN');
    });
  });
}
