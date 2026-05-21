import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_entity.freezed.dart';

@freezed
class ArticleEntity with _$ArticleEntity {
  const factory ArticleEntity({
    required String id,
    required String title,
    required String? description,
    required String? content,
    required String? urlToImage,
    required String url,
    required String? author,
    required String sourceName,
    required DateTime publishedAt,
    required String readTime,
    @Default(false) bool isBookmarked,
  }) = _ArticleEntity;
}
