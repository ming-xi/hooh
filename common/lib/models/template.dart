import 'package:common/models/user.dart';
import 'package:common/utils/serialization.dart';
import 'package:json_annotation/json_annotation.dart';

part 'template.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Template {
  String frameHeight;
  String frameWidth;
  String frameX;
  String frameY;
  String id;
  String imageUrl;
  int profitInt;
  int state;
  String textColor;
  DateTime? createdAt;
  DateTime featuredAt;
  bool favorited;
  int favoriteCount;
  int useCount;
  User? author;

  Template(this.frameHeight, this.frameWidth, this.frameX, this.frameY, this.id, this.imageUrl, this.profitInt, this.state, this.textColor, this.createdAt,
      this.featuredAt, this.favorited, this.favoriteCount, this.useCount, this.author);

  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}
