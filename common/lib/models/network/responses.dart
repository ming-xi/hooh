import 'package:common/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'responses.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginResponse {
  User user;
  JWTResponse jwtResponse;

  LoginResponse(this.user, this.jwtResponse);

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class JWTResponse {
  String accessToken;
  String refreshToken;
  int accessTokenExpiration;
  int refreshTokenExpiration;

  JWTResponse(this.accessToken, this.refreshToken, this.accessTokenExpiration, this.refreshTokenExpiration);

  factory JWTResponse.fromJson(Map<String, dynamic> json) => _$JWTResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JWTResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ValidateAccountResponse {
  String token;

  ValidateAccountResponse(this.token);

  factory ValidateAccountResponse.fromJson(Map<String, dynamic> json) => _$ValidateAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateAccountResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RequestValidationCodeResponse {
  static const typeEmail = 0;
  static const typeMobile = 1;
  String code;

  RequestValidationCodeResponse(this.code);

  factory RequestValidationCodeResponse.fromJson(Map<String, dynamic> json) => _$RequestValidationCodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RequestValidationCodeResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ValidateCodeResponse {
  String token;

  ValidateCodeResponse(this.token);

  factory ValidateCodeResponse.fromJson(Map<String, dynamic> json) => _$ValidateCodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateCodeResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RequestUploadingFileResponse {
  String uploadingUrl;
  String key;

  RequestUploadingFileResponse(this.uploadingUrl, this.key);

  factory RequestUploadingFileResponse.fromJson(Map<String, dynamic> json) => _$RequestUploadingFileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RequestUploadingFileResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RecommendedTag {
  String name;
  int? type;

  RecommendedTag(this.name, this.type);

  factory RecommendedTag.fromJson(Map<String, dynamic> json) => _$RecommendedTagFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendedTagToJson(this);
}
