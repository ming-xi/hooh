import 'package:app/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
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

  void setFollowState(bool newState, {Function(HoohApiErrorResponse error)? callback}) {
    if (state.user == null) {
      return;
    }
    Future<void> request = newState ? network.followUser(state.userId) : network.cancelFollowUser(state.userId);
    network.requestAsync<void>(request, (newData) {
      state.user!.followed = newState;
      updateState(state.copyWith(user: User.fromJson(state.user!.toJson())));
    }, (error) {
      if (callback != null) {
        callback(error);
      }
    });
  }
}
