import 'package:json_annotation/json_annotation.dart';

part 'requests.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginWithPasswordRequest {
  String username;
  String encryptedPassword;

  LoginWithPasswordRequest(this.username, this.encryptedPassword);

  factory LoginWithPasswordRequest.fromJson(Map<String, dynamic> json) => _$LoginWithPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginWithPasswordRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterRequest {
  String username;
  String email;
  String encryptedPassword;

  RegisterRequest(this.username, this.email, this.encryptedPassword);

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RequestValidationCodeRequest {
  int type;
  String target;

  RequestValidationCodeRequest(this.type, this.target);

  factory RequestValidationCodeRequest.fromJson(Map<String, dynamic> json) => _$RequestValidationCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestValidationCodeRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ValidateCodeRequest {
  String target;
  String code;

  ValidateCodeRequest(this.target, this.code);

  factory ValidateCodeRequest.fromJson(Map<String, dynamic> json) => _$ValidateCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateCodeRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ResetPasswordRequest {
  String token;
  String encryptedPassword;

  ResetPasswordRequest(this.token, this.encryptedPassword);

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RequestUploadingFileRequest {
  String md5;
  String ext;

  RequestUploadingFileRequest(this.md5, this.ext);

  factory RequestUploadingFileRequest.fromJson(Map<String, dynamic> json) => _$RequestUploadingFileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestUploadingFileRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ChangeUserInfoRequest {
  String? name;
  String? signature;
  String? website;
  String? avatarKey;

  ChangeUserInfoRequest({this.name, this.signature, this.website, this.avatarKey});

  factory ChangeUserInfoRequest.fromJson(Map<String, dynamic> json) => _$ChangeUserInfoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeUserInfoRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshTokenRequest {
  String refreshToken;

  RefreshTokenRequest(this.refreshToken);

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}
