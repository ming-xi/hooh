import 'package:json_annotation/json_annotation.dart';

part 'gallery_category.g.dart';

enum GalleryCategoryType { normal, local, favorite, newest, trending, unknown }

@JsonSerializable()
class GalleryCategory {
  final String safeId;

  final String? name;

  final GalleryCategoryType? type;

  GalleryCategory({required this.safeId, required this.name, required this.type});

  factory GalleryCategory.fromJson(Map<String, dynamic> json) => _$GalleryCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$GalleryCategoryToJson(this);
}
