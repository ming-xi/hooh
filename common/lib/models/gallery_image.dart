import 'package:json_annotation/json_annotation.dart';

part 'gallery_image.g.dart';

// enum GalleryImageType { normal, local, favorite, newest, trending, unknown }

@JsonSerializable()
class GalleryImage {
  @JsonKey(name: "safe_id")
  String safeId;
  @JsonKey(name: "image_url")
  String imageUrl;

  // final GalleryImageType? type;

  GalleryImage({required this.safeId, required this.imageUrl});

  factory GalleryImage.fromJson(Map<String, dynamic> json) => _$GalleryImageFromJson(json);

  Map<String, dynamic> toJson() => _$GalleryImageToJson(this);
}
