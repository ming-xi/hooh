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
class ValidateCodeResponse {
  String code;

  ValidateCodeResponse(this.code);
  factory ValidateCodeResponse.fromJson(Map<String, dynamic> json) => _$ValidateCodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateCodeResponseToJson(this);
}
