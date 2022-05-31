import 'package:common/utils/serialization.dart';
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
  int? followerCount;
  int? followingCount;
  int? postCount;
  int? publicPostCount;
  int? likeCount;
  int? commentCount;
  int? templateCount;
  String? avatarUrl;
  String? badgeImageUrl;
  String? signature;
  String? website;
  List<String>? receivedBadges;

  bool? followed;

  DateTime? createdAt; // 创建时间

  int? register_step;

  User(this.id,
      this.name,
      this.username,
      this.followerCount,
      this.followingCount,
      this.postCount,
      this.publicPostCount,
      this.likeCount,
      this.commentCount,
      this.templateCount,
      this.avatarUrl,
      this.badgeImageUrl,
      this.signature,
      this.website,
      this.receivedBadges,
      this.followed,
      this.createdAt,
      this.register_step);

  bool hasFinishedRegisterSteps() {
    return register_step! == REGISTER_STEP_COMPLETED;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserBadge {
  String imageUrl;
  User designer;
  int serialNumber;
  DateTime createdAt;

  UserBadge(this.imageUrl, this.designer, this.serialNumber, this.createdAt);

  factory UserBadge.fromJson(Map<String, dynamic> json) => _$UserBadgeFromJson(json);

  Map<String, dynamic> toJson() => _$UserBadgeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserActivity {
  static const int TYPE_CREATE_POST = 0;
  static const int TYPE_CREATE_TEMPLATE = 1;
  static const int TYPE_LIKE_POST = 2;
  static const int TYPE_COMMENT_POST = 3;
  static const int TYPE_VOTE_POST = 4;
  static const int TYPE_FAVORITE_TEMPLATE = 5;
  static const int TYPE_FOLLOW_USER = 6;
  static const int TYPE_CANCEL_FOLLOW_USER = 7;
  static const int TYPE_FOLLOW_TAG = 8;
  static const int TYPE_CANCEL_FOLLOW_TAG = 9;
  static const int TYPE_CREATE_BADGE = 10;
  static const int TYPE_RECEIVE_BADGE = 11;

  int type;
  String universalLink;
  Map<String, dynamic> data;
  DateTime createdAt;

  UserActivity(this.type, this.universalLink, this.data, this.createdAt);

  factory UserActivity.fromJson(Map<String, dynamic> json) => _$UserActivityFromJson(json);

  Map<String, dynamic> toJson() => _$UserActivityToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class WalletLog {
  static const int POW_TYPE_CREATE_COMMENT = 0;
  static const int POW_TYPE_VIEW_PAGE_OF_TYPE_A = 1;
  static const int POW_TYPE_VIEW_PAGE_OF_TYPE_B = 2;
  static const int POW_TYPE_LIKE_POST = 3;
  static const int POW_TYPE_LIKE_COMMENT = 4;
  static const int POW_TYPE_TEMPLATE_APPROVED = 5;

  static const int REPUTATION_TYPE_MY_POST_COMMENTED = 0;
  static const int REPUTATION_TYPE_MY_POST_LIKED = 1;
  static const int REPUTATION_TYPE_MY_COMMENT_REPLIED = 2;
  static const int REPUTATION_TYPE_MY_COMMENT_LIKED = 3;
  static const int REPUTATION_TYPE_MY_TEMPLATE_USED = 4;

  static const int COST_TYPE_INTO_WAITING_LIST = 0;
  static const int COST_TYPE_CREATE_BADGE = 1;
  static const int COST_TYPE_DELETE_ACTIVITY = 2;
  static const int COST_TYPE_VOTE_POST = 3;

  int activityType;
  @JsonKey(fromJson: Serialization.doubleFromJson, toJson: Serialization.doubleToJson)
  double currentProfitFactor;
  @JsonKey(fromJson: Serialization.doubleFromJson, toJson: Serialization.doubleToJson)
  double finalProfit;
  @JsonKey(fromJson: Serialization.doubleFromJson, toJson: Serialization.doubleToJson)
  double originalProfit;
  DateTime createdAt;

  WalletLog(this.activityType, this.currentProfitFactor, this.finalProfit, this.originalProfit, this.createdAt);

  factory WalletLog.fromJson(Map<String, dynamic> json) => _$WalletLogFromJson(json);

  Map<String, dynamic> toJson() => _$WalletLogToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SystemNotification {
  static const int TYPE_POST_COMMENTED = 0;
  static const int TYPE_COMMENT_REPLIED = 1;
  static const int TYPE_POST_LIKED = 2;
  static const int TYPE_POST_FAVORITED = 3;
  static const int TYPE_COMMENT_LIKED = 4;
  static const int TYPE_POST_MOVED_TO_MAIN_LIST = 5;
  static const int TYPE_POST_VOTED = 6;
  static const int TYPE_TEMPLATE_APPROVED = 7;
  static const int TYPE_BADGE_RECEIVED = 8;
  static const int TYPE_POST_DELETED = 9;
  static const int TYPE_TEMPLATE_FAVORITED = 10;
  static const int TYPE_FOLLOWED = 11;

  int type;
  String? title;
  String? avatarUrl;
  String? avatarUniversalLink;
  String? content;
  String mainUniversalLink;
  String? imageUrl;
  DateTime createdAt;

  SystemNotification(this.type, this.title, this.avatarUrl, this.avatarUniversalLink, this.content, this.mainUniversalLink, this.imageUrl, this.createdAt);

  factory SystemNotification.fromJson(Map<String, dynamic> json) => _$SystemNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$SystemNotificationToJson(this);
}
