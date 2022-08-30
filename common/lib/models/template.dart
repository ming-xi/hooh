import 'package:common/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'template.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Template {
  static const STATE_PENDING = 0;
  static const STATE_FEATURED = 1;
  static const STATE_REJECTED = 2;

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
  DateTime? featuredAt;
  List<String>? tags;
  bool favorited;
  int favoriteCount;
  int useCount;
  User? author;

  Template(this.frameHeight, this.frameWidth, this.frameX, this.frameY, this.id, this.imageUrl, this.profitInt, this.state, this.textColor, this.createdAt,
      this.featuredAt, this.tags, this.favorited, this.favoriteCount, this.useCount, this.author);

  factory Template.fromJson(Map<String, dynamic> json) => _$TemplateFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateToJson(this);

  static String getStateText(int state) {
    switch (state) {
      case Template.STATE_PENDING:
        return "待审核";
      case Template.STATE_FEATURED:
        return "已过审";
      case Template.STATE_REJECTED:
        return "已拒绝";
      default:
        return "未知";
    }
  }
}
