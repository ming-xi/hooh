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
  String? followerCount;
  String? followingCount;
  String? postCount;
  String? publicPostCount;
  String? likeCount;
  String? commentCount;
  String? avatarUrl;
  String? signature;
  String? website;

  DateTime? createdAt; // 创建时间

  int? register_step;

  User(this.id, this.name, this.username, this.avatarUrl, this.signature, this.website, this.createdAt, this.register_step);

  bool hasFinishedRegisterSteps() {
    return register_step! == REGISTER_STEP_COMPLETED;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
