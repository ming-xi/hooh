import 'package:common/models/user.dart';
import 'package:common/utils/serialization.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Post {
  /// 不加入waiting list
  static const int PUBLISH_STATE_NORMAL = 0;

  /// 在waiting list
  static const int PUBLISH_STATE_WAITING_LIST = 1;

  /// 已精选
  static const int PUBLISH_STATE_MAIN_LIST = 2;

  String id;
  User author;
  int commentCount;
  int likeCount;
  int? voteCount;
  int? myVoteCount;
  int profitInt;
  List<PostImage> images;
  List<String>? tags;
  bool liked;
  bool? favorited;
  bool visible;
  int publishState;
  DateTime? likedAt;
  DateTime? favoritedAt;
  DateTime? featuredAt;
  DateTime createdAt;

  Post(this.id, this.author, this.commentCount, this.likeCount, this.voteCount, this.myVoteCount, this.profitInt, this.images, this.tags, this.liked,
      this.favorited, this.visible, this.publishState, this.likedAt, this.favoritedAt, this.featuredAt, this.createdAt);

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class PostImage {
  String imageUrl;
  String? templateId;
  bool hidden;
  bool? templateFavorited;

  PostImage(this.imageUrl, this.templateId, this.hidden, this.templateFavorited);

  factory PostImage.fromJson(Map<String, dynamic> json) => _$PostImageFromJson(json);

  Map<String, dynamic> toJson() => _$PostImageToJson(this);
}
