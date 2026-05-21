import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/read_time_estimator.dart';
import '../../domain/entities/article_entity.dart';

part 'article_model.freezed.dart';
part 'article_model.g.dart';

@freezed
class ArticleModel with _$ArticleModel {
  const factory ArticleModel({
    ArticleSourceModel? source,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
  }) = _ArticleModel;

  factory ArticleModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleModelFromJson(json);
}

@freezed
class ArticleSourceModel with _$ArticleSourceModel {
  const factory ArticleSourceModel({String? id, String? name}) =
      _ArticleSourceModel;

  factory ArticleSourceModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleSourceModelFromJson(json);
}

/// Extension to map DTO → Domain entity.
extension ArticleModelMapper on ArticleModel {
  ArticleEntity toEntity() {
    final id = url ?? DateTime.now().toIso8601String();

    DateTime publishedDate;
    try {
      publishedDate = publishedAt != null
          ? DateTime.parse(publishedAt!)
          : DateTime.now();
    } catch (_) {
      publishedDate = DateTime.now();
    }

    return ArticleEntity(
      id: id,
      title: title ?? 'No Title',
      description: description,
      content: content,
      urlToImage: urlToImage,
      url: id,
      author: author,
      sourceName: source?.name ?? 'Unknown',
      publishedAt: publishedDate,
      readTime: ReadTimeEstimator.estimate(content),
    );
  }
}
