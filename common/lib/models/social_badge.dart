import 'package:common/utils/serialization.dart';
import 'package:json_annotation/json_annotation.dart';

part 'social_badge.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SocialBadgeTemplateLayer {
  int layerIndex;

  String imageUrl;

  bool mutable;

  String hue;

  SocialBadgeTemplateLayer(this.layerIndex, this.imageUrl, this.mutable, this.hue);

  factory SocialBadgeTemplateLayer.fromJson(Map<String, dynamic> json) => _$SocialBadgeTemplateLayerFromJson(json);

  Map<String, dynamic> toJson() => _$SocialBadgeTemplateLayerToJson(this);
}
