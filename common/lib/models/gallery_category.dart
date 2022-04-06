import 'package:json_annotation/json_annotation.dart';

part 'gallery_category.g.dart';

// enum GalleryCategoryType { normal, local, favorite, newest, trending, unknown }

@JsonSerializable(fieldRename: FieldRename.snake)
class GalleryCategory {
  @JsonKey(name: "safe_id")
  String safeId;

  String? name;

  // final GalleryCategoryType? type;

  GalleryCategory({required this.safeId});

  factory GalleryCategory.fromJson(Map<String, dynamic> json) => _$GalleryCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$GalleryCategoryToJson(this);
}
