import 'package:common/utils/serialization.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  String id;
  String name; // 昵称
  String? avatarUrl;
  String? signature;
  String? website;

  DateTime? createdAt; // 创建时间

  int? register_step;

  User({required this.id, required this.name}); // 注册步骤 0 完成设置密码， 1 完成设置社交徽章

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
