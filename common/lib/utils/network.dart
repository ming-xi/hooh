import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/requests.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/post.dart';
import 'package:common/models/post_comment.dart';
import 'package:common/models/social_badge.dart';
import 'package:common/models/template.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/device_info.dart';
import 'package:common/utils/preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_json/pretty_json.dart';

//顶层变量
Network network = Network._internal();

enum HttpMethod { get, post, put, delete }

class Network {
  /// 顶层变量，单例模式
  Network._internal() {
    _prepareHttpClient();
  }

  static const HOST_LOCAL = "192.168.31.136:8080";
  // static const HOST_LOCAL = "192.168.3.100:8080";
  static const HOST_STAGING = "stgapi.hooh.zone";
  static const HOST_PRODUCTION = "api.hooh.zone";
  static const SERVER_HOSTS = {
    TYPE_LOCAL: HOST_LOCAL,
    TYPE_STAGING: HOST_STAGING,
    TYPE_PRODUCTION: HOST_PRODUCTION,
  };
  static const SERVER_HOST_NAMES = {
    TYPE_LOCAL: "LOCAL",
    TYPE_STAGING: "STAGING",
    TYPE_PRODUCTION: "PRODUCTION",
  };

  static const TYPE_LOCAL = 0;
  static const TYPE_STAGING = 1;
  static const TYPE_PRODUCTION = 2;

  static const SERVER_PATH_PREFIX = "";
  static const DEFAULT_PAGE_SIZE = 20;
  static const DEFAULT_PAGE = 1;

  late int serverType;

  late final http.Client _client;
  bool _isUsingLocalServer = false;

  void requestAsync<T>(Future<T> request, Function(T data) onSuccess, Function(HoohApiErrorResponse error) onError) {
    request.then((data) {
      onSuccess(data);
    }).catchError((Object error, StackTrace stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      if (error is HoohApiErrorResponse) {
        onError(error);
      }
    });
  }

  void setUserToken(String? token) {
    preferences.putString(Preferences.KEY_USER_ACCESS_TOKEN, token);
  }

  void reloadServerType() {
    serverType = preferences.getInt(Preferences.KEY_SERVER) ?? TYPE_PRODUCTION;
  }

  String getS3ImageKey(String? url) {
    if (url == null) {
      return "";
    }
    if (url.contains("?") && url.contains("com/")) {
      return url.substring(url.indexOf("com/") + "com/".length, url.indexOf("?"));
    }
    return url;
  }

  // Future<ValidateCodeResponse> requestValidationCodeForRegister(int countryCode, String mobile) {
  //   return _getResponseObject<ValidateCodeResponse>(HttpMethod.post, _buildHoohUri("users/register/request-validation-code"),
  //       body: ValidateMobileRequest(countryCode, mobile).toJson(), deserializer: ValidateCodeResponse.fromJson);
  // }
  //
  // Future<ValidateAccountResponse> validationCodeForRegister(int countryCode, String mobile, String code) {
  //   return _getResponseObject<ValidateAccountResponse>(HttpMethod.post, _buildHoohUri("users/register/validate"),
  //       body: ValidateAccountRequest(countryCode, mobile, code).toJson(), deserializer: ValidateAccountResponse.fromJson);
  // }
  //
  // Future<LoginResponse> register(String token, String password) {
  //   String encryptedPassword = sha512.convert(utf8.encode(password)).toString();
  //   return _getResponseObject<LoginResponse>(HttpMethod.post, _buildHoohUri("users/register"),
  //       body: RegisterRequest(token, encryptedPassword).toJson(), deserializer: LoginResponse.fromJson);
  // }

  //region register

  Future<LoginResponse> register(String username, String password, String email) {
    String encryptedPassword = sha512.convert(utf8.encode(password)).toString();
    return _getResponseObject<LoginResponse>(HttpMethod.post, _buildHoohUri("users/register"),
        body: RegisterRequest(username, email, encryptedPassword).toJson(), deserializer: LoginResponse.fromJson);
  }

  Future<LoginResponse> login(String username, String password) {
    String encryptedPassword = sha512.convert(utf8.encode(password)).toString();
    return _getResponseObject<LoginResponse>(HttpMethod.post, _buildHoohUri("users/login"),
        body: LoginWithPasswordRequest(username, encryptedPassword).toJson(), deserializer: LoginResponse.fromJson);
  }

  Future<void> resetPasswordRequestValidationCode(String target, int type) {
    assert([RequestValidationCodeResponse.TYPE_EMAIL, RequestValidationCodeResponse.TYPE_MOBILE].contains(type));
    return _getResponseObject<void>(HttpMethod.post, _buildHoohUri("users/reset-password/request-validation-code"),
        body: RequestValidationCodeRequest(type, target).toJson());
  }

  Future<ValidateCodeResponse> resetPasswordValidateCode(String target, String code) {
    return _getResponseObject<ValidateCodeResponse>(HttpMethod.post, _buildHoohUri("users/reset-password/validate"),
        body: ValidateCodeRequest(target, code).toJson(), deserializer: ValidateCodeResponse.fromJson);
  }

  Future<User> resetPassword(String token, String password) {
    String encryptedPassword = sha512.convert(utf8.encode(password)).toString().toLowerCase();
    return _getResponseObject<User>(HttpMethod.post, _buildHoohUri("users/reset-password"),
        body: ResetPasswordRequest(token, encryptedPassword).toJson(), deserializer: User.fromJson);
  }

  Future<void> bindAccountRequestValidationCode(String target, int type) {
    assert([RequestValidationCodeResponse.TYPE_EMAIL, RequestValidationCodeResponse.TYPE_MOBILE].contains(type));
    return _getResponseObject<void>(
      HttpMethod.post,
      _buildHoohUri("users/binding/request-validation-code"),
      body: RequestValidationCodeRequest(type, target).toJson(),
    );
  }

  Future<User> bindAccountValidateCode(String target, String code) {
    return _getResponseObject<User>(HttpMethod.post, _buildHoohUri("users/binding/validate"),
        body: ValidateCodeRequest(target, code).toJson(), deserializer: User.fromJson);
  }

  //endregion

  //region user
  Future<User> getUserInfo(String userId) {
    return _getResponseObject<User>(HttpMethod.get, _buildHoohUri("users/$userId"), deserializer: User.fromJson);
  }

  Future<List<Template>> getUserCreatedTemplates(String userId, {DateTime? date, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<Template>(HttpMethod.get, _buildHoohUri("users/$userId/templates", params: params), deserializer: Template.fromJson);
  }

  Future<List<Post>> getUserCreatedPosts(String userId, {DateTime? date, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<Post>(HttpMethod.get, _buildHoohUri("users/$userId/posts/created", params: params), deserializer: Post.fromJson);
  }

  Future<List<Post>> getUserLikedPosts(String userId, {DateTime? date, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<Post>(HttpMethod.get, _buildHoohUri("users/$userId/posts/liked", params: params), deserializer: Post.fromJson);
  }

  Future<List<Post>> getUserFavoritedPosts(String userId, {DateTime? date, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<Post>(HttpMethod.get, _buildHoohUri("users/$userId/posts/favorited", params: params), deserializer: Post.fromJson);
  }

  Future<UserWalletResponse> getUserWalletInfo(String userId) {
    return _getResponseObject<UserWalletResponse>(HttpMethod.get, _buildHoohUri("users/$userId/wallet"), deserializer: UserWalletResponse.fromJson);
  }

  Future<UserWalletOverviewResponse> getUserWalletOverview(String userId) {
    return _getResponseObject<UserWalletOverviewResponse>(HttpMethod.get, _buildHoohUri("users/$userId/wallet/overview"),
        deserializer: UserWalletOverviewResponse.fromJson);
  }

  Future<List<WalletLog>> getWalletPowLogs(String userId) {
    return _getResponseList<WalletLog>(HttpMethod.get, _buildHoohUri("users/$userId/wallet/activities/pow"), deserializer: WalletLog.fromJson);
  }

  Future<List<WalletLog>> getWalletReputationLogs(String userId) {
    return _getResponseList<WalletLog>(HttpMethod.get, _buildHoohUri("users/$userId/wallet/activities/reputation"), deserializer: WalletLog.fromJson);
  }

  Future<List<WalletLog>> getWalletCostLogs(String userId) {
    return _getResponseList<WalletLog>(HttpMethod.get, _buildHoohUri("users/$userId/wallet/activities/cost"), deserializer: WalletLog.fromJson);
  }

  Future<List<SocialBadgeTemplateLayer>> getRandomBadgeTemplate(String userId) {
    return _getResponseList<SocialBadgeTemplateLayer>(HttpMethod.get, _buildHoohUri("users/$userId/random-badge"),
        deserializer: SocialBadgeTemplateLayer.fromJson);
  }

  Future<User> changeUserInfo(String userId, {String? name, String? signature, String? website, String? avatarKey, String? badgeImageKey}) {
    return _getResponseObject<User>(HttpMethod.put, _buildHoohUri("users/$userId"),
        body: ChangeUserInfoRequest(
          name: name,
          signature: signature,
          website: website,
          avatarKey: avatarKey,
          badgeImageKey: badgeImageKey,
        ).toJson(),
        deserializer: User.fromJson);
  }

  Future<void> addFcmToken(String userId, String token) {
    return _getResponseObject<void>(
      HttpMethod.post,
      _buildHoohUri("users/$userId/fcm-tokens"),
      body: FcmTokenRequest(token).toJson(),
    );
  }

  Future<void> deleteFcmToken(String userId, String token) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("users/$userId/fcm-tokens"),
      body: FcmTokenRequest(token).toJson(),
    );
  }

  Future<RequestUploadingFileResponse> requestUploadingAvatar(String userId, File file) {
    String fileMd5 = md5.convert(file.readAsBytesSync()).toString().toLowerCase();
    String ext = file.path;
    debugPrint("upload file md5=$fileMd5 path=$ext");
    ext = ext.substring(ext.lastIndexOf(".") + 1);
    return _getResponseObject<RequestUploadingFileResponse>(HttpMethod.post, _buildHoohUri("users/$userId/request-uploading-avatar"),
        body: RequestUploadingFileRequest(fileMd5, ext).toJson(), deserializer: RequestUploadingFileResponse.fromJson);
  }

  Future<RequestUploadingFileResponse> requestUploadingSocialBadge(String userId, File file) {
    String fileMd5 = md5.convert(file.readAsBytesSync()).toString().toLowerCase();
    String ext = file.path;
    debugPrint("upload file md5=$fileMd5 path=$ext");
    ext = ext.substring(ext.lastIndexOf(".") + 1);
    return _getResponseObject<RequestUploadingFileResponse>(HttpMethod.post, _buildHoohUri("users/$userId/request-uploading-badge"),
        body: RequestUploadingFileRequest(fileMd5, ext).toJson(), deserializer: RequestUploadingFileResponse.fromJson);
  }

  Future<FollowUserResponse> followUser(String userId) {
    return _getResponseObject<FollowUserResponse>(HttpMethod.put, _buildHoohUri("users/$userId/follow"), deserializer: FollowUserResponse.fromJson);
  }

  Future<void> cancelFollowUser(String userId) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("users/$userId/follow"),
    );
  }

  Future<List<User>> getFollowers(String userId) {
    return _getResponseList<User>(HttpMethod.get, _buildHoohUri("users/$userId/followers"), deserializer: User.fromJson);
  }

  Future<List<User>> getFollowings(String userId) {
    return _getResponseList<User>(HttpMethod.get, _buildHoohUri("users/$userId/followings"), deserializer: User.fromJson);
  }

  Future<UserBadgeStatsResponse> getUserBadgeStats(String userId) {
    return _getResponseObject<UserBadgeStatsResponse>(HttpMethod.get, _buildHoohUri("users/$userId/badges/stats"),
        deserializer: UserBadgeStatsResponse.fromJson);
  }

  Future<List<UserBadge>> getUserReceivedBadges(String userId, {int page = DEFAULT_PAGE, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "page": page,
      "size": size,
    };
    return _getResponseList<UserBadge>(HttpMethod.get, _buildHoohUri("users/$userId/badges", params: params), deserializer: UserBadge.fromJson);
  }

  Future<UserActivityResponse> getUserActivities(String userId, {DateTime? date, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseObject<UserActivityResponse>(HttpMethod.get, _buildHoohUri("users/$userId/activities", params: params),
        deserializer: UserActivityResponse.fromJson);
  }

  Future<void> deleteUserActivity(String userId, String id) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("users/$userId/activities/$id"),
    );
  }

  Future<List<SystemNotification>> getSystemNotifications({DateTime? date, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<SystemNotification>(HttpMethod.get, _buildHoohUri("users/notifications", params: params),
        deserializer: SystemNotification.fromJson);
  }

  Future<UnreadNotificationCountResponse> getUnreadNotificationCount() {
    int milliSeconds = preferences.getInt(Preferences.KEY_LAST_SYSTEM_NOTIFICATIONS_READ) ?? 0;
    Map<String, dynamic> params = {"timestamp": DateUtil.getUtcDateString(DateTime.fromMillisecondsSinceEpoch(milliSeconds))};
    return _getResponseObject<UnreadNotificationCountResponse>(HttpMethod.get, _buildHoohUri("users/notifications/unread-count", params: params),
        deserializer: UnreadNotificationCountResponse.fromJson);
  }

  //endregion

  //region template
  static const SEARCH_TEMPLATE_TYPE_RECENT = 0;
  static const SEARCH_TEMPLATE_TYPE_TRENDING = 1;
  static const SEARCH_TEMPLATE_TYPE_FAVORITED = 2;
  static const SEARCH_TEMPLATE_TYPES = [
    SEARCH_TEMPLATE_TYPE_RECENT,
    SEARCH_TEMPLATE_TYPE_TRENDING,
    SEARCH_TEMPLATE_TYPE_FAVORITED,
  ];

  Future<List<Template>> searchTemplatesByTag(String tag, DateTime date, {int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "tag": tag,
      "timestamp": DateUtil.getUtcDateString(date),
      "size": size,
    };
    return _getResponseList<Template>(HttpMethod.get, _buildHoohUri("templates/search", params: params), deserializer: Template.fromJson);
  }

  Future<List<Template>> searchTemplatesByType(int type, {DateTime? date, int page = 1, int size = DEFAULT_PAGE_SIZE}) {
    if (!SEARCH_TEMPLATE_TYPES.contains(type)) {
      throw Exception("invalid type: $type");
    }
    Map<String, dynamic> params = {
      "type": type,
      "size": size,
    };
    if (type == SEARCH_TEMPLATE_TYPE_TRENDING) {
      params["page"] = page;
    } else {
      params["timestamp"] = DateUtil.getUtcDateString(date!);
    }
    return _getResponseList<Template>(HttpMethod.get, _buildHoohUri("templates/search", params: params), deserializer: Template.fromJson);
  }

  Future<List<RecommendedTag>> getRecommendedTags() {
    return _getResponseList(HttpMethod.get, _buildHoohUri("templates/recommended-tags"), deserializer: RecommendedTag.fromJson);
  }

  Future<RequestUploadingFileResponse> requestUploadingTemplate(File file) {
    String fileMd5 = md5.convert(file.readAsBytesSync()).toString().toLowerCase();
    String ext = file.path;
    debugPrint("upload file md5=$fileMd5 path=$ext");
    ext = ext.substring(ext.lastIndexOf(".") + 1);
    return _getResponseObject<RequestUploadingFileResponse>(HttpMethod.post, _buildHoohUri("templates/request-uploading-template"),
        body: RequestUploadingFileRequest(fileMd5, ext).toJson(), deserializer: RequestUploadingFileResponse.fromJson);
  }

  Future<Template> createTemplate(CreateTemplateRequest request) {
    return _getResponseObject<Template>(HttpMethod.post, _buildHoohUri("templates/create"), body: request.toJson(), deserializer: Template.fromJson);
  }

  Future<void> favoriteTemplate(String templateId) {
    return _getResponseObject<void>(
      HttpMethod.put,
      _buildHoohUri("templates/$templateId/favorite"),
    );
  }

  Future<void> cancelFavoriteTemplate(String templateId) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("templates/$templateId/favorite"),
    );
  }

  Future<void> deleteTemplate(String templateId) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("templates/$templateId"),
    );
  }

  Future<List<Template>> getRecommendedTemplates(List<String> contents) {
    return _getResponseList(HttpMethod.post, _buildHoohUri("templates/recommend-for-creation"),
        body: GetRecommendedTemplatesForCreationRequest(contents).toJson(), deserializer: Template.fromJson);
  }

  Future<Template> getTemplateInfo(String id) {
    return _getResponseObject(HttpMethod.get, _buildHoohUri("templates/$id"), deserializer: Template.fromJson);
  }

  //endregion
  //region post

  Future<Post> getPostInfo(String id) {
    return _getResponseObject<Post>(HttpMethod.get, _buildHoohUri("posts/$id"), deserializer: Post.fromJson);
  }

  Future<List<String>> getRecommendedPublishPostTags() {
    return _getResponseList(
      HttpMethod.get,
      _buildHoohUri("posts/recommended-publish-tags"),
    );
  }

  Future<RequestUploadingFileResponse> requestUploadingPostImage(File file) {
    String fileMd5 = md5.convert(file.readAsBytesSync()).toString().toLowerCase();
    String ext = file.path;
    debugPrint("upload file md5=$fileMd5 path=$ext");
    ext = ext.substring(ext.lastIndexOf(".") + 1);
    return _getResponseObject<RequestUploadingFileResponse>(HttpMethod.post, _buildHoohUri("posts/request-uploading-post-image"),
        body: RequestUploadingFileRequest(fileMd5, ext).toJson(), deserializer: RequestUploadingFileResponse.fromJson);
  }

  Future<Post> createPost(CreatePostRequest request) {
    return _getResponseObject<Post>(HttpMethod.post, _buildHoohUri("posts/create"), body: request.toJson(), deserializer: Post.fromJson);
  }

  Future<Post> editPost(String id, EditPostRequest request) {
    return _getResponseObject<Post>(HttpMethod.put, _buildHoohUri("posts/$id"), body: request.toJson(), deserializer: Post.fromJson);
  }

  Future<void> deletePost(String id) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("posts/$id"),
    );
  }

  Future<List<Post>> getWaitingListPosts({required bool trending, DateTime? date, int? page, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (page != null) {
      params["page"] = page;
    }
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<Post>(HttpMethod.get, _buildHoohUri("posts/waiting-list/${trending ? "trending" : "recent"}", params: params),
        deserializer: Post.fromJson);
  }

  Future<List<Post>> getMainListPosts({required bool trending, DateTime? date, int? page, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (page != null) {
      params["page"] = page;
    }
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<Post>(HttpMethod.get, _buildHoohUri("posts/main-list/${trending ? "trending" : "recent"}", params: params),
        deserializer: Post.fromJson);
  }

  Future<TagDetailResponse> getTagDetail(String tagName) {
    return _getResponseObject<TagDetailResponse>(HttpMethod.get, _buildHoohUri("post-tags/$tagName"), deserializer: TagDetailResponse.fromJson);
  }

  Future<List<Post>> getTaggedPosts(String tagName, {required bool trending, DateTime? date, int? page, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (page != null) {
      params["page"] = page;
    }
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<Post>(HttpMethod.get, _buildHoohUri("post-tags/$tagName/posts/${trending ? "trending" : "recent"}", params: params),
        deserializer: Post.fromJson);
  }

  Future<List<Post>> getFollowedUserPosts({required bool trending, DateTime? date, int? page, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (page != null) {
      params["page"] = page;
    }
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<Post>(HttpMethod.get, _buildHoohUri("posts/followed-users/${trending ? "trending" : "recent"}", params: params),
        deserializer: Post.fromJson);
  }

  Future<Post> votePost(String postId) {
    return _getResponseObject<Post>(HttpMethod.put, _buildHoohUri("posts/$postId/vote"), deserializer: Post.fromJson);
  }

  Future<void> likePost(String postId) {
    return _getResponseObject<void>(
      HttpMethod.put,
      _buildHoohUri("posts/$postId/like"),
    );
  }

  Future<void> cancelLikePost(String postId) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("posts/$postId/like"),
    );
  }

  Future<void> favoritePost(String postId) {
    return _getResponseObject<void>(
      HttpMethod.put,
      _buildHoohUri("posts/$postId/favorite"),
    );
  }

  Future<void> cancelFavoritePost(String postId) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("posts/$postId/favorite"),
    );
  }

  Future<List<User>> getPostLikes(String id, {int page = DEFAULT_PAGE, int size = 100}) {
    Map<String, dynamic> params = {
      "page": page,
      "size": size,
    };
    return _getResponseList<User>(HttpMethod.get, _buildHoohUri("posts/$id/likes", params: params), deserializer: User.fromJson);
  }

  Future<List<PostComment>> getPostComments(String id, {DateTime? date, int size = DEFAULT_PAGE_SIZE}) {
    Map<String, dynamic> params = {
      "size": size,
    };
    if (date != null) {
      params["timestamp"] = DateUtil.getUtcDateString(date);
    }
    return _getResponseList<PostComment>(HttpMethod.get, _buildHoohUri("posts/$id/comments", params: params), deserializer: PostComment.fromJson);
  }

  //endregion

  //region comments
  // Future<List<PostComment>> getCommentComments(String id, {DateTime? date, int size = DEFAULT_PAGE_SIZE}) {
  //   Map<String, dynamic> params = {
  //     "size": size,
  //   };
  //   if (date != null) {
  //     params["timestamp"] = DateUtil.getUtcDateString(date);
  //   }
  //   return _getResponseList<PostComment>(HttpMethod.get, _buildHoohUri("post-comments/$id/comments", params: params), deserializer: PostComment.fromJson);
  // }

  Future<PostComment> createPostComment(String id, CreatePostCommentRequest request) {
    return _getResponseObject<PostComment>(HttpMethod.post, _buildHoohUri("posts/$id/comments"), body: request.toJson(), deserializer: PostComment.fromJson);
  }

  Future<PostComment> replyComment(String id, CreatePostCommentRequest request) {
    return _getResponseObject<PostComment>(HttpMethod.post, _buildHoohUri("post-comments/$id/comments"),
        body: request.toJson(), deserializer: PostComment.fromJson);
  }

  Future<void> deletePostComment(String id) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("post-comments/$id"),
    );
  }

  Future<void> likePostComment(String id) {
    return _getResponseObject<void>(
      HttpMethod.put,
      _buildHoohUri("post-comments/$id/like"),
    );
  }

  Future<void> cancelLikePostComment(String id) {
    return _getResponseObject<void>(
      HttpMethod.delete,
      _buildHoohUri("post-comments/$id/like"),
    );
  }

  //endregion

  //region misc

  Future<HomepageBackgroundImageResponse> getHomepageRandomBackground() {
    return _getResponseObject(HttpMethod.get, _buildHoohUri("app/random-homepage-background-image"), deserializer: HomepageBackgroundImageResponse.fromJson);
  }

  Future<FeeInfoResponse> getFeeInfo() {
    return _getResponseObject(HttpMethod.get, _buildHoohUri("app/info/fee"), deserializer: FeeInfoResponse.fromJson);
  }

  Future<ChangeNameLimitInfoResponse> getChangeNameLimitInfo() {
    return _getResponseObject(HttpMethod.get, _buildHoohUri("app/info/change-name-limit"), deserializer: ChangeNameLimitInfoResponse.fromJson);
  }

  //endregion
//
//   //region old api
//
//   Future<List<GalleryCategory>> getGalleryCategoryList() {
//     return _getResponseList<GalleryCategory>(HttpMethod.get, _buildHoohUri("gallery/categoriesV4"), deserializer: GalleryCategory.fromJson);
//   }
//
//   Future<List<GalleryImage>> getGalleryImageList(String id, int page, int width, {int size = 20}) {
//     return _getResponseList<GalleryImage>(
//         HttpMethod.get, _buildHoohUri("gallery/categories/$id/imagesV3", params: {"page": page, "width": width, "size": size}),
//         deserializer: GalleryImage.fromJson);
//   }
//
//   Future<List<GalleryImage>> searchGalleryImageList(String key, int page, int width, bool showFavoriteStatus, {int size = 20}) {
//     return _getResponseList<GalleryImage>(HttpMethod.get,
//         _buildHoohUri("gallery/images/query", params: {"page": page, "width": width, "size": size, "key": key, "show_favorite_status": showFavoriteStatus}),
//         deserializer: GalleryImage.fromJson);
//   }
//
//   Future<void> setGalleryImageFavorite(String id, bool favorite) {
//     return _getResponseObject<void>(favorite ? HttpMethod.put : HttpMethod.delete, _buildHoohUri("gallery/images/$id/favorite"));
//   }
//
// //endregion
  //region upload and download file

  Future<bool> uploadFile(String url, Uint8List fileBytes) async {
    int id = Random().nextInt(10000);
    logRequest(id, HttpMethod.put, Uri.parse(url), {'data': "<file bytes>"});
    var response = await http.put(Uri.parse(url), body: fileBytes);
    logResponse(id, response, null);
    if (response.statusCode >= 200 && response.statusCode < 400) {
      return true;
    } else {
      return false;
    }
  }

  Future<DownloadInfo?> downloadBytes(String url, String filename) async {
    try {
      int id = Random().nextInt(10000);
      logRequest(id, HttpMethod.get, Uri.parse(url), null);
      final response = await http.get(Uri.parse(url));
      logResponse(id, response, null);
      if (response.contentLength == 0) {
        return null;
      }
      return DownloadInfo(bytes: response.bodyBytes, filename: filename);
    } catch (e) {
      print(e);
      return null;
    }
  }

//endregion
//region core

  Future<M> _getResponseObject<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders, Map<String, dynamic>? body, M Function(Map<String, dynamic>)? deserializer}) async {
    extraHeaders ??= {};
    _prepareHeaders(extraHeaders);
    var data = await _getRawResponse(method, uri, extraHeaders: extraHeaders, body: body, deserializer: deserializer);
    if (data is HoohApiErrorResponse) {
      return Future.error(data);
    } else {
      if (deserializer != null) {
        return deserializer(data as Map<String, dynamic>);
      } else {
        return Future.value(null);
      }
    }
  }

  Future<List<M>> _getResponseList<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders, Map<String, dynamic>? body, M Function(Map<String, dynamic>)? deserializer}) async {
    extraHeaders ??= {};
    // extraHeaders["Authorization"] =
    //     "Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsInVzZXJfc2FmZV9pZCI6ImRlOTkyYWVkLWEyYzctNGEzZS05YzZkLTU3YmM3YTEyNWYwYyIsImV4cCI6MTY1MDA5ODgwNywiaWF0IjoxNjQ3NTA2ODA3fQ.pcqeofRYGPQ0fvIIn5ZdSOkEGNyU-trFaqWcyDBOAvJyi-bHSLhqCzwOjDRDF6fJ-BzqMQkg-_IRr61Hq4baBg";
    _prepareHeaders(extraHeaders);
    var data = await _getRawResponse(method, uri, extraHeaders: extraHeaders, body: body, deserializer: deserializer);
    if (data is HoohApiErrorResponse) {
      return Future.error(data);
    } else {
      if (M == String) {
        return (data as List<dynamic>).map((e) => e as M).toList();
      } else {
        if (deserializer != null) {
          return (data as List<dynamic>).map((e) => deserializer(e as Map<String, dynamic>)).toList();
        } else {
          return Future.value([]);
        }
      }
    }
  }

// Future<String> _getUserAgent() async {
//
// }
  void _prepareHeaders(Map<String, dynamic> headers) {
    String? token = preferences.getString(Preferences.KEY_USER_ACCESS_TOKEN);
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }
    headers["Content-Type"] = "application/json";
    headers["User-Agent"] = deviceInfo.getUserAgent();
    // headers["Language"] = Platform.localeName;
    headers["Accept-Language"] = Platform.localeName;
  }

  Future<dynamic> _getRawResponse<M>(HttpMethod method, Uri uri,
      {Map<String, dynamic>? extraHeaders, Map<String, dynamic>? body, M Function(Map<String, dynamic>)? deserializer}) async {
    int id = Random().nextInt(10000);
    logRequest(id, method, uri, body);
    http.Response response;
    try {
      switch (method) {
        case HttpMethod.get:
          response = await _client.get(uri, headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
          break;
        case HttpMethod.post:
          response = await _client.post(uri, body: json.encode(body), headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
          break;
        case HttpMethod.put:
          response = await _client.put(uri, body: json.encode(body), headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
          break;
        case HttpMethod.delete:
          response = await _client.delete(uri, body: json.encode(body), headers: extraHeaders?.map((key, value) => MapEntry(key, value.toString())));
          break;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    dynamic returnedJson;
    try {
      if (response.bodyBytes.isNotEmpty) {
        returnedJson = jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    try {
      logResponse(id, response, returnedJson);
    } catch (e) {
      debugPrint(e.toString());
    }
    if (response.statusCode >= 200 && response.statusCode < 400) {
      //success
      return returnedJson;
    } else {
      //failed
      HoohApiErrorResponse hoohApiErrorResponse;
      if (returnedJson != null) {
        hoohApiErrorResponse = HoohApiErrorResponse.fromJson(returnedJson);
        if (hoohApiErrorResponse.message.isEmpty) {
          hoohApiErrorResponse.message = "<未返回错误信息>";
        }
      } else {
        hoohApiErrorResponse = HoohApiErrorResponse(500, "<无法解析>", "<无法解析>");
      }
      return hoohApiErrorResponse;
    }
  }

  void logResponse(int id, http.Response response, dynamic returnedJson) {
    debugPrint("[RESPONSE $id] HTTP ${response.statusCode}\njson=${returnedJson == null ? "null" : prettyJson(returnedJson)}");
  }

  void logRequest(int id, HttpMethod method, Uri uri, Map<String, dynamic>? body) {
    debugPrint(
        "[REQUEST  $id] ${method.name.toUpperCase()} url=${uri.toString()},\n query:${"\n" + prettyJson(uri.queryParameters)},\n body:${body == null ? "null" : ("\n" + prettyJson(body))}");
  }

  Uri _buildUri(bool ssl, String host, String path, {Map<String, dynamic>? params}) {
    var queryParameters = params?.map((key, value) => MapEntry(key, value.toString()));
    return ssl ? Uri.https(host, path, queryParameters) : Uri.http(host, path, queryParameters);
  }

  Uri _buildHoohUri(String path, {bool hasPrefix = true, Map<String, dynamic>? params}) {
    String unencodedPath = (hasPrefix ? SERVER_PATH_PREFIX : "") + path;
    return _buildUri(serverType != TYPE_LOCAL, SERVER_HOSTS[serverType] ?? HOST_PRODUCTION, unencodedPath, params: params);
  }

  void _prepareHttpClient() {
    reloadServerType();
    _client = http.Client();
  }
//endregion
//   ///准备一个可以支持Let's Encrypt证书的client
//   void _prepareHttpClient() {
// //     /// This is LetsEncrypt's self-signed trusted root certificate authority
// //     /// certificate, issued under common name: ISRG Root X1 (Internet Security
// //     /// Research Group).  Used in handshakes to negotiate a Transport Layer Security
// //     /// connection between endpoints.  This certificate is missing from older devices
// //     /// that don't get OS updates such as Android 7 and older.  But, we can supply
// //     /// this certificate manually to our HttpClient via SecurityContext so it can be
// //     /// used when connecting to URLs protected by LetsEncrypt SSL certificates.
// //     /// PEM format LE self-signed cert from here: https://letsencrypt.org/certificates/
// //     const String ISRG_X1 = """-----BEGIN CERTIFICATE-----
// // MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
// // TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
// // cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
// // WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
// // ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
// // MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
// // h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
// // 0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
// // A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
// // T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
// // B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
// // B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
// // KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
// // OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
// // jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
// // qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
// // rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
// // HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
// // hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
// // ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
// // 3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
// // NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
// // ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
// // TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
// // jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
// // oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
// // 4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
// // mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
// // emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
// // -----END CERTIFICATE-----""";
// //     HttpClient customHttpClient(String? cert) {
// //       SecurityContext context = SecurityContext.defaultContext;
// //       try {
// //         if (cert != null) {
// //           Uint8List bytes = Uint8List.fromList(utf8.encode(cert));
// //           context.setTrustedCertificatesBytes(bytes);
// //         }
// //         print('createHttpClient() - cert added!');
// //       } on TlsException catch (e) {
// //         print(e);
// //       } finally {}
// //       HttpClient httpClient = HttpClient(context: context);
// //       return httpClient;
// //     }
// //
// //     /// Use package:http Client with our custom dart:io HttpClient with added
// //     /// LetsEncrypt trusted certificate
// //     http.Client createLEClient() {
// //       IOClient ioClient;
// //       ioClient = IOClient(customHttpClient(ISRG_X1));
// //       return ioClient;
// //     }
// //
// //     /// Using a custom package:http Client
// //     /// that will work with devices missing LetsEncrypt
// //     /// ISRG Root X1 certificates, like old Android 7 devices.
// //     _client = createLEClient();
//     _client = http.Client();
//   }
}

class DownloadInfo {
  Uint8List? bytes;
  String? filename;

  DownloadInfo({this.bytes, this.filename});
}
