// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GalleryCategory _$GalleryCategoryFromJson(Map<String, dynamic> json) =>
    GalleryCategory(
      safeId: json['safeId'] as String,
      name: json['name'] as String?,
      type: $enumDecodeNullable(_$GalleryCategoryTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$GalleryCategoryToJson(GalleryCategory instance) =>
    <String, dynamic>{
      'safeId': instance.safeId,
      'name': instance.name,
      'type': _$GalleryCategoryTypeEnumMap[instance.type],
    };

const _$GalleryCategoryTypeEnumMap = {
  GalleryCategoryType.normal: 'normal',
  GalleryCategoryType.local: 'local',
  GalleryCategoryType.favorite: 'favorite',
  GalleryCategoryType.newest: 'newest',
  GalleryCategoryType.trending: 'trending',
  GalleryCategoryType.unknown: 'unknown',
};
