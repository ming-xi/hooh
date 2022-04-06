import 'package:json_annotation/json_annotation.dart';

part 'requests.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginWithPasswordRequest {
  int countryCode;
  String mobile;
  String encryptedPassword;

  LoginWithPasswordRequest(this.countryCode, this.mobile, this.encryptedPassword);

  factory LoginWithPasswordRequest.fromJson(Map<String, dynamic> json) => _$LoginWithPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginWithPasswordRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterRequest {
  String encryptedPassword;
  String token;

  RegisterRequest(this.token, this.encryptedPassword);

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ValidateAccountRequest {
  int countryCode;
  String mobile;
  String code;

  ValidateAccountRequest(this.countryCode, this.mobile, this.code);

  factory ValidateAccountRequest.fromJson(Map<String, dynamic> json) => _$ValidateAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateAccountRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ValidateMobileRequest {
  int countryCode;
  String mobile;

  ValidateMobileRequest(this.countryCode, this.mobile);

  factory ValidateMobileRequest.fromJson(Map<String, dynamic> json) => _$ValidateMobileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateMobileRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshTokenRequest {
  String refreshToken;

  RefreshTokenRequest(this.refreshToken);

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}
