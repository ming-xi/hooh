import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  // 注册步骤 0 完成设置密码， 1 完成设置社交徽章
  static const REGISTER_STEP_SET_SOCIAL_ICON = 0;
  static const REGISTER_STEP_COMPLETED = 1;

  String id;
  String name; // 昵称
  String? username;
  int? followerCount;
  int? followingCount;
  int? postCount;
  int? publicPostCount;
  int? likeCount;
  int? commentCount;
  int? templateCount;
  String? avatarUrl;
  String? badgeImageUrl;
  String? signature;
  String? website;
  List<String>? receivedBadges;

  bool? followed;

  DateTime? createdAt; // 创建时间

  int? register_step;

  User(
      this.id,
      this.name,
      this.username,
      this.followerCount,
      this.followingCount,
      this.postCount,
      this.publicPostCount,
      this.likeCount,
      this.commentCount,
      this.templateCount,
      this.avatarUrl,
      this.badgeImageUrl,
      this.signature,
      this.website,
      this.receivedBadges,
      this.followed,
      this.createdAt,
      this.register_step);

  bool hasFinishedRegisterSteps() {
    return register_step! == REGISTER_STEP_COMPLETED;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserBadge {
  String imageUrl;
  User designer;
  int serialNumber;
  DateTime createdAt;

  UserBadge(this.imageUrl, this.designer, this.serialNumber, this.createdAt);

  factory UserBadge.fromJson(Map<String, dynamic> json) => _$UserBadgeFromJson(json);

  Map<String, dynamic> toJson() => _$UserBadgeToJson(this);
}
