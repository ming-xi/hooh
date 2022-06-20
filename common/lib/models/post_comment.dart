import 'package:common/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_comment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class PostComment {
  String id;
  User author;
  User? repliedUser;
  String content;
  List<Substitute> substitutes;

  // List<PostComment>? subComments;
  int likeCount;
  int commentCount;
  bool? liked;

  DateTime? createdAt;

  PostComment(this.id, this.author, this.repliedUser, this.content, this.substitutes, this.likeCount, this.commentCount, this.liked, this.createdAt);

  factory PostComment.fromJson(Map<String, dynamic> json) => _$PostCommentFromJson(json);

  Map<String, dynamic> toJson() => _$PostCommentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Substitute {
  static const TYPE_MENTION = 0;
  static const TYPE_URL = 1;
  String text;
  String data;
  int type;

  Substitute(this.text, this.data, this.type);

  factory Substitute.fromJson(Map<String, dynamic> json) => _$SubstituteFromJson(json);

  Map<String, dynamic> toJson() => _$SubstituteToJson(this);
}
