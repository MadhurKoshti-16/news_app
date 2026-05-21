// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleHiveModelAdapter extends TypeAdapter<ArticleHiveModel> {
  @override
  final int typeId = 0;

  @override
  ArticleHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      content: fields[3] as String?,
      urlToImage: fields[4] as String?,
      url: fields[5] as String,
      author: fields[6] as String?,
      sourceName: fields[7] as String,
      publishedAt: fields[8] as DateTime,
      readTime: fields[9] as String,
      isBookmarked: fields[10] as bool,
      cachedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleHiveModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.urlToImage)
      ..writeByte(5)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.author)
      ..writeByte(7)
      ..write(obj.sourceName)
      ..writeByte(8)
      ..write(obj.publishedAt)
      ..writeByte(9)
      ..write(obj.readTime)
      ..writeByte(10)
      ..write(obj.isBookmarked)
      ..writeByte(11)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
