import 'package:app/utils/ui_utils.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'user_profile_view_model.g.dart';

@CopyWith()
class UserProfileScreenModelState {
  final String userId;
  final User? user;
  final bool isLoading;

  UserProfileScreenModelState({required this.userId, this.user, this.isLoading = true});

  factory UserProfileScreenModelState.init(String id) => UserProfileScreenModelState(userId: id);
}

class UserProfileScreenViewModel extends StateNotifier<UserProfileScreenModelState> {
  UserProfileScreenViewModel(UserProfileScreenModelState state) : super(state) {
    getUserInfo();
  }

  void getUserInfo({Function()? callback}) {
    updateState(state.copyWith(isLoading: true));
    network.requestAsync<User>(network.getUserInfo(state.userId), (newData) {
      updateState(state.copyWith(isLoading: false, user: newData));
      if (callback != null) {
        callback();
      }
    }, (error) {
      updateState(state.copyWith(isLoading: false));
    });
  }

  void setFollowState(BuildContext context, bool newState, {Function()? onSuccess, Function(HoohApiErrorResponse error)? onFailure}) {
    if (state.user == null) {
      return;
    }
    Future request = newState ? network.followUser(state.userId) : network.cancelFollowUser(state.userId);
    network.requestAsync(request, (data) {
      if (onSuccess != null) {
        onSuccess();
      }
      if (data is FollowUserResponse && data.receivedBadge != null) {
        showReceiveBadgeDialog(context, data.receivedBadge!);
      }
      state.user!.followed = newState;
      updateState(state.copyWith(user: User.fromJson(state.user!.toJson())));
    }, (error) {
      if (onFailure != null) {
        onFailure(error);
      }
    });
  }
}
