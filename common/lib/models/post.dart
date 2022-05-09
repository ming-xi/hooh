import 'package:common/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Post {
  String id;
  User author;
  int commentCount;
  int likeCount;
  List<PostImage> images;
  bool liked;
  bool favorited;
  bool public;
  bool allowDownload;
  int publishState;
  DateTime featuredAt;
  DateTime createdAt;

  Post(this.id, this.author, this.commentCount, this.likeCount, this.images, this.liked, this.favorited, this.public, this.allowDownload, this.publishState,
      this.featuredAt, this.createdAt);

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
