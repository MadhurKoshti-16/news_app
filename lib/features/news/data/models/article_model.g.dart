// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArticleModelImpl _$$ArticleModelImplFromJson(Map<String, dynamic> json) =>
    _$ArticleModelImpl(
      source: json['source'] == null
          ? null
          : ArticleSourceModel.fromJson(json['source'] as Map<String, dynamic>),
      author: json['author'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$$ArticleModelImplToJson(_$ArticleModelImpl instance) =>
    <String, dynamic>{
      'source': instance.source,
      'author': instance.author,
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'urlToImage': instance.urlToImage,
      'publishedAt': instance.publishedAt,
      'content': instance.content,
    };

_$ArticleSourceModelImpl _$$ArticleSourceModelImplFromJson(
  Map<String, dynamic> json,
) => _$ArticleSourceModelImpl(
  id: json['id'] as String?,
  name: json['name'] as String?,
);

Map<String, dynamic> _$$ArticleSourceModelImplToJson(
  _$ArticleSourceModelImpl instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
