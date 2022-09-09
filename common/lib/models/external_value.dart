import 'package:common/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'external_value.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ExternalValue {
  static const int TYPE_INT = 0;
  static const int TYPE_DOUBLE = 1;
  static const int TYPE_STRING = 2;
  static const int TYPE_OBJECT = 3;
  static const int TYPE_ARRAY = 4;
  String key;
  String value;
  int type;
  String des;
  DateTime createdAt;
  DateTime updatedAt;
  User? user;

  ExternalValue(this.key, this.value, this.type, this.des, this.createdAt, this.updatedAt, this.user);

  factory ExternalValue.fromJson(Map<String, dynamic> json) => _$ExternalValueFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalValueToJson(this);
}
