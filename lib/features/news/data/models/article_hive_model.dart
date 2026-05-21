import 'package:hive/hive.dart';
import '../../domain/entities/article_entity.dart';

part 'article_hive_model.g.dart';

@HiveType(typeId: 0)
class ArticleHiveModel extends HiveObject {
  ArticleHiveModel({
    required this.id,
    required this.title,
    this.description,
    this.content,
    this.urlToImage,
    required this.url,
    this.author,
    required this.sourceName,
    required this.publishedAt,
    required this.readTime,
    this.isBookmarked = false,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now();

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? content;

  @HiveField(4)
  String? urlToImage;

  @HiveField(5)
  String url;

  @HiveField(6)
  String? author;

  @HiveField(7)
  String sourceName;

  @HiveField(8)
  DateTime publishedAt;

  @HiveField(9)
  String readTime;

  @HiveField(10)
  bool isBookmarked;

  @HiveField(11)
  DateTime cachedAt;
}

extension ArticleHiveModelMapper on ArticleHiveModel {
  ArticleEntity toEntity() => ArticleEntity(
    id: id,
    title: title,
    description: description,
    content: content,
    urlToImage: urlToImage,
    url: url,
    author: author,
    sourceName: sourceName,
    publishedAt: publishedAt,
    readTime: readTime,
    isBookmarked: isBookmarked,
  );
}

extension ArticleEntityToHive on ArticleEntity {
  ArticleHiveModel toHiveModel() => ArticleHiveModel(
    id: id,
    title: title,
    description: description,
    content: content,
    urlToImage: urlToImage,
    url: url,
    author: author,
    sourceName: sourceName,
    publishedAt: publishedAt,
    readTime: readTime,
    isBookmarked: isBookmarked,
  );
}
