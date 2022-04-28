import 'package:common/utils/serialization.dart';
import 'package:json_annotation/json_annotation.dart';

part 'template.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Template {
  String frameHeight;
  String frameWidth;
  String frameX;
  String frameY;
  String id;
  String imageUrl;
  String authorName;
  int state;
  String textColor;
  DateTime featuredAt;
  bool favorited;

  Template(this.frameHeight, this.frameWidth, this.frameX, this.frameY, this.id, this.imageUrl, this.authorName, this.state, this.textColor, this.featuredAt,
      this.favorited);

  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}
