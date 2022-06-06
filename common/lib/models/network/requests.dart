import 'package:common/models/post_comment.dart';
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
  String? badgeImageKey;

  ChangeUserInfoRequest({this.name, this.signature, this.website, this.avatarKey, this.badgeImageKey});

  factory ChangeUserInfoRequest.fromJson(Map<String, dynamic> json) => _$ChangeUserInfoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeUserInfoRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateTemplateRequest {
  String frameHeight;
  String frameWidth;
  String frameX;
  String frameY;
  List<String>? tags;
  String imageKey;
  String textColor;

  CreateTemplateRequest(
      {required this.frameHeight,
      required this.frameWidth,
      required this.frameX,
      required this.frameY,
      this.tags,
      required this.imageKey,
      required this.textColor});

  factory CreateTemplateRequest.fromJson(Map<String, dynamic> json) => _$CreateTemplateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTemplateRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshTokenRequest {
  String refreshToken;

  RefreshTokenRequest(this.refreshToken);

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreatePostRequest {
  List<CreateImageRequest> images;
  List<String> tags;
  bool allowDownload;
  bool visible;

  bool joinWaitingList;

  CreatePostRequest({required this.images, required this.tags, required this.allowDownload, required this.visible, required this.joinWaitingList});

  factory CreatePostRequest.fromJson(Map<String, dynamic> json) => _$CreatePostRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateImageRequest {
  String imageKey;
  String content;
  String? templateId;

  CreateImageRequest(this.imageKey, this.content, {this.templateId});

  factory CreateImageRequest.fromJson(Map<String, dynamic> json) => _$CreateImageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateImageRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GetRecommendedTemplatesForCreationRequest {
  List<String> contents;

  GetRecommendedTemplatesForCreationRequest(this.contents);

  factory GetRecommendedTemplatesForCreationRequest.fromJson(Map<String, dynamic> json) => _$GetRecommendedTemplatesForCreationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GetRecommendedTemplatesForCreationRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreatePostCommentRequest {
  List<Substitute> substitutes;
  String content;

  CreatePostCommentRequest(this.substitutes, this.content);

  factory CreatePostCommentRequest.fromJson(Map<String, dynamic> json) => _$CreatePostCommentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostCommentRequestToJson(this);
}
