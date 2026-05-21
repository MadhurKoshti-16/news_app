// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ArticleEntity {
  /// Unique identifier: we use the article URL as a stable ID.
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String? get urlToImage => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  String get sourceName => throw _privateConstructorUsedError;
  DateTime get publishedAt => throw _privateConstructorUsedError;

  /// Computed at mapping time from [content] word count.
  String get readTime => throw _privateConstructorUsedError;

  /// Whether this article has been bookmarked by the user.
  bool get isBookmarked => throw _privateConstructorUsedError;

  /// Create a copy of ArticleEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleEntityCopyWith<ArticleEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleEntityCopyWith<$Res> {
  factory $ArticleEntityCopyWith(
    ArticleEntity value,
    $Res Function(ArticleEntity) then,
  ) = _$ArticleEntityCopyWithImpl<$Res, ArticleEntity>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? content,
    String? urlToImage,
    String url,
    String? author,
    String sourceName,
    DateTime publishedAt,
    String readTime,
    bool isBookmarked,
  });
}

/// @nodoc
class _$ArticleEntityCopyWithImpl<$Res, $Val extends ArticleEntity>
    implements $ArticleEntityCopyWith<$Res> {
  _$ArticleEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? content = freezed,
    Object? urlToImage = freezed,
    Object? url = null,
    Object? author = freezed,
    Object? sourceName = null,
    Object? publishedAt = null,
    Object? readTime = null,
    Object? isBookmarked = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            urlToImage: freezed == urlToImage
                ? _value.urlToImage
                : urlToImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            author: freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceName: null == sourceName
                ? _value.sourceName
                : sourceName // ignore: cast_nullable_to_non_nullable
                      as String,
            publishedAt: null == publishedAt
                ? _value.publishedAt
                : publishedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            readTime: null == readTime
                ? _value.readTime
                : readTime // ignore: cast_nullable_to_non_nullable
                      as String,
            isBookmarked: null == isBookmarked
                ? _value.isBookmarked
                : isBookmarked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleEntityImplCopyWith<$Res>
    implements $ArticleEntityCopyWith<$Res> {
  factory _$$ArticleEntityImplCopyWith(
    _$ArticleEntityImpl value,
    $Res Function(_$ArticleEntityImpl) then,
  ) = __$$ArticleEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? content,
    String? urlToImage,
    String url,
    String? author,
    String sourceName,
    DateTime publishedAt,
    String readTime,
    bool isBookmarked,
  });
}

/// @nodoc
class __$$ArticleEntityImplCopyWithImpl<$Res>
    extends _$ArticleEntityCopyWithImpl<$Res, _$ArticleEntityImpl>
    implements _$$ArticleEntityImplCopyWith<$Res> {
  __$$ArticleEntityImplCopyWithImpl(
    _$ArticleEntityImpl _value,
    $Res Function(_$ArticleEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArticleEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? content = freezed,
    Object? urlToImage = freezed,
    Object? url = null,
    Object? author = freezed,
    Object? sourceName = null,
    Object? publishedAt = null,
    Object? readTime = null,
    Object? isBookmarked = null,
  }) {
    return _then(
      _$ArticleEntityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        urlToImage: freezed == urlToImage
            ? _value.urlToImage
            : urlToImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        author: freezed == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceName: null == sourceName
            ? _value.sourceName
            : sourceName // ignore: cast_nullable_to_non_nullable
                  as String,
        publishedAt: null == publishedAt
            ? _value.publishedAt
            : publishedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        readTime: null == readTime
            ? _value.readTime
            : readTime // ignore: cast_nullable_to_non_nullable
                  as String,
        isBookmarked: null == isBookmarked
            ? _value.isBookmarked
            : isBookmarked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ArticleEntityImpl implements _ArticleEntity {
  const _$ArticleEntityImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.urlToImage,
    required this.url,
    required this.author,
    required this.sourceName,
    required this.publishedAt,
    required this.readTime,
    this.isBookmarked = false,
  });

  /// Unique identifier: we use the article URL as a stable ID.
  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? content;
  @override
  final String? urlToImage;
  @override
  final String url;
  @override
  final String? author;
  @override
  final String sourceName;
  @override
  final DateTime publishedAt;

  /// Computed at mapping time from [content] word count.
  @override
  final String readTime;

  /// Whether this article has been bookmarked by the user.
  @override
  @JsonKey()
  final bool isBookmarked;

  @override
  String toString() {
    return 'ArticleEntity(id: $id, title: $title, description: $description, content: $content, urlToImage: $urlToImage, url: $url, author: $author, sourceName: $sourceName, publishedAt: $publishedAt, readTime: $readTime, isBookmarked: $isBookmarked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.urlToImage, urlToImage) ||
                other.urlToImage == urlToImage) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.sourceName, sourceName) ||
                other.sourceName == sourceName) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.readTime, readTime) ||
                other.readTime == readTime) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    content,
    urlToImage,
    url,
    author,
    sourceName,
    publishedAt,
    readTime,
    isBookmarked,
  );

  /// Create a copy of ArticleEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleEntityImplCopyWith<_$ArticleEntityImpl> get copyWith =>
      __$$ArticleEntityImplCopyWithImpl<_$ArticleEntityImpl>(this, _$identity);
}

abstract class _ArticleEntity implements ArticleEntity {
  const factory _ArticleEntity({
    required final String id,
    required final String title,
    required final String? description,
    required final String? content,
    required final String? urlToImage,
    required final String url,
    required final String? author,
    required final String sourceName,
    required final DateTime publishedAt,
    required final String readTime,
    final bool isBookmarked,
  }) = _$ArticleEntityImpl;

  /// Unique identifier: we use the article URL as a stable ID.
  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get content;
  @override
  String? get urlToImage;
  @override
  String get url;
  @override
  String? get author;
  @override
  String get sourceName;
  @override
  DateTime get publishedAt;

  /// Computed at mapping time from [content] word count.
  @override
  String get readTime;

  /// Whether this article has been bookmarked by the user.
  @override
  bool get isBookmarked;

  /// Create a copy of ArticleEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleEntityImplCopyWith<_$ArticleEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
