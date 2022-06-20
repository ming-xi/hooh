import 'package:app/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'followers_view_model.g.dart';

@CopyWith()
class FollowerScreenModelState {
  final String userId;
  final List<User> users;
  final bool isFollower;
  final PageState pageState;
  final HoohApiErrorResponse? error;
  final DateTime? lastTimestamp;

  FollowerScreenModelState({
    required this.userId,
    required this.users,
    required this.pageState,
    required this.isFollower,
    this.error,
    this.lastTimestamp,
  });

  factory FollowerScreenModelState.init(String userId, bool isFollower) => FollowerScreenModelState(
        users: [],
        userId: userId,
        isFollower: isFollower,
        pageState: PageState.inited,
      );
}

class FollowerScreenViewModel extends StateNotifier<FollowerScreenModelState> {
  FollowerScreenViewModel(FollowerScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getUsers(null);
  }

  void getUsers(Function(PageState)? callback, {bool isRefresh = true}) {
    if (isRefresh) {
      updateState(state.copyWith(lastTimestamp: null));
      if (state.pageState == PageState.loading) {
        if (callback != null) {
          callback(state.pageState);
        }
        return;
      }
    } else {
      if (![
        PageState.dataLoaded,
      ].contains(state.pageState)) {
        if (callback != null) {
          callback(state.pageState);
        }
        return;
      }
    }
    updateState(state.copyWith(pageState: PageState.loading));
    // debugPrint("lastTimestamp=${state.lastTimestamp}");
    Future<List<User>> request;
    if (state.isFollower) {
      request = network.getFollowers(state.userId);
    } else {
      request = network.getFollowings(state.userId);
    }
    network.requestAsync<List<User>>(request, (newData) {
      if (newData.isEmpty) {
        //no data
        if (isRefresh) {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore, users: []));
        } else {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore));
        }
        // debugPrint("${state.pageState}");
      } else {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(pageState: PageState.dataLoaded, users: newData, lastTimestamp: newData.last.createdAt));
        } else {
          updateState(state.copyWith(pageState: PageState.dataLoaded, users: [...state.users, ...newData], lastTimestamp: newData.last.createdAt));
        }
      }
      if (callback != null) {
        callback(state.pageState);
      }
    }, (error) {
      updateState(state.copyWith(
        error: error,
        pageState: PageState.inited,
      ));
      if (callback != null) {
        callback(state.pageState);
      }
    });
  }

  void setFollowState(String userId, bool newState, {Function(HoohApiErrorResponse error)? callback}) {
    Future<void> request = newState ? network.followUser(userId) : network.cancelFollowUser(userId);
    for (var user in state.users) {
      if (user.id == userId) {
        user.followed = newState;
      }
    }
    network.requestAsync<void>(request, (newData) {
      updateState(state.copyWith(users: [...state.users]));
    }, (error) {
      if (callback != null) {
        callback(error);
      }
    });
  }
}
