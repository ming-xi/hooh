import 'package:common/utils/serialization.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  String name;  // 昵称

  DateTime? createdAt;  // 创建时间

  int? register_step;  // 注册步骤 0 完成设置密码， 1 完成设置昵称， 2 完成设置社交徽章

  User({required this.name});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

}
