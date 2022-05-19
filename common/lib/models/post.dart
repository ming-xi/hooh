import 'package:common/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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
  List<PostImage> images;
  List<String>? tags;
  bool liked;
  bool favorited;
  bool visible;
  bool allowDownload;
  int publishState;
  DateTime? featuredAt;
  DateTime createdAt;

  Post(this.id, this.author, this.commentCount, this.likeCount, this.voteCount, this.myVoteCount, this.images, this.tags, this.liked, this.favorited,
      this.visible, this.allowDownload, this.publishState, this.featuredAt, this.createdAt);

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PostImage {
  String imageUrl;
  bool hidden;

  PostImage(this.imageUrl, this.hidden);

  factory PostImage.fromJson(Map<String, dynamic> json) => _$PostImageFromJson(json);

  Map<String, dynamic> toJson() => _$PostImageToJson(this);
}
