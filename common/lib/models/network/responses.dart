import 'package:common/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'responses.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class LoginResponse {
  User user;
  JWTResponse jwtResponse;

  LoginResponse(this.user, this.jwtResponse);

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class JWTResponse {
  String accessToken;
  String refreshToken;
  int accessTokenExpiration;
  int refreshTokenExpiration;

  JWTResponse(this.accessToken, this.refreshToken, this.accessTokenExpiration, this.refreshTokenExpiration);

  factory JWTResponse.fromJson(Map<String, dynamic> json) => _$JWTResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JWTResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ValidateAccountResponse {
  String token;

  ValidateAccountResponse(this.token);

  factory ValidateAccountResponse.fromJson(Map<String, dynamic> json) => _$ValidateAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateAccountResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class RequestValidationCodeResponse {
  static const typeEmail = 0;
  static const typeMobile = 1;
  String code;

  RequestValidationCodeResponse(this.code);

  factory RequestValidationCodeResponse.fromJson(Map<String, dynamic> json) => _$RequestValidationCodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RequestValidationCodeResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ValidateCodeResponse {
  String token;

  ValidateCodeResponse(this.token);

  factory ValidateCodeResponse.fromJson(Map<String, dynamic> json) => _$ValidateCodeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ValidateCodeResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class RequestUploadingFileResponse {
  String uploadingUrl;
  String key;

  RequestUploadingFileResponse(this.uploadingUrl, this.key);

  factory RequestUploadingFileResponse.fromJson(Map<String, dynamic> json) => _$RequestUploadingFileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RequestUploadingFileResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class RecommendedTag {
  String name;
  int? type;

  RecommendedTag(this.name, this.type);

  factory RecommendedTag.fromJson(Map<String, dynamic> json) => _$RecommendedTagFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendedTagToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class HomepageBackgroundImageResponse {
  String imageUrl;

  HomepageBackgroundImageResponse(this.imageUrl);

  factory HomepageBackgroundImageResponse.fromJson(Map<String, dynamic> json) => _$HomepageBackgroundImageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HomepageBackgroundImageResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserBadgeStatsResponse {
  int createdBadgeCount;
  int receivedBadgeCount;
  List<UserCreatedBadge> createdBadges;

  UserBadgeStatsResponse(this.createdBadgeCount, this.receivedBadgeCount, this.createdBadges);

  factory UserBadgeStatsResponse.fromJson(Map<String, dynamic> json) => _$UserBadgeStatsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserBadgeStatsResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserCreatedBadge {
  String imageUrl;
  int ownerAmount;
  DateTime createdAt;

  @JsonKey(ignore: true)
  late String displayDate;

  UserCreatedBadge(this.imageUrl, this.ownerAmount, this.createdAt);

  factory UserCreatedBadge.fromJson(Map<String, dynamic> json) => _$UserCreatedBadgeFromJson(json);

  Map<String, dynamic> toJson() => _$UserCreatedBadgeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserActivityResponse {
  User user;
  List<UserActivity> activities;

  UserActivityResponse(this.user, this.activities);

  factory UserActivityResponse.fromJson(Map<String, dynamic> json) => _$UserActivityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserActivityResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserWalletResponse {
  int balanceInt;
  int totalCostInt;
  int totalEarnedPowInt;
  int totalEarnedReputationInt;
  int yesterdayEarnedPowInt;
  int yesterdayEarnedReputationInt;

  UserWalletResponse(
      this.balanceInt, this.totalCostInt, this.totalEarnedPowInt, this.totalEarnedReputationInt, this.yesterdayEarnedPowInt, this.yesterdayEarnedReputationInt);

  factory UserWalletResponse.fromJson(Map<String, dynamic> json) => _$UserWalletResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserWalletResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class FeeInfoResponse {
  int joinWaitingList;
  int createBadge;
  int deleteActivity;
  int votePost;

  FeeInfoResponse(this.joinWaitingList, this.createBadge, this.deleteActivity, this.votePost);

  factory FeeInfoResponse.fromJson(Map<String, dynamic> json) => _$FeeInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FeeInfoResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ChangeNameLimitInfoResponse {
  int days;

  ChangeNameLimitInfoResponse(this.days);

  factory ChangeNameLimitInfoResponse.fromJson(Map<String, dynamic> json) => _$ChangeNameLimitInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeNameLimitInfoResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UnreadNotificationCountResponse {
  int unreadCount;

  UnreadNotificationCountResponse(this.unreadCount);

  factory UnreadNotificationCountResponse.fromJson(Map<String, dynamic> json) => _$UnreadNotificationCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadNotificationCountResponseToJson(this);
}
