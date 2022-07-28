import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'activities_view_model.g.dart';

@CopyWith()
class ActivitiesScreenModelState {
  final String userId;
  final User? user;
  final List<UserActivity> activities;
  final PageState pageState;
  final HoohApiErrorResponse? error;
  final DateTime? lastTimestamp;

  ActivitiesScreenModelState({
    required this.userId,
    required this.activities,
    required this.pageState,
    this.user,
    this.error,
    this.lastTimestamp,
  });

  factory ActivitiesScreenModelState.init(String id) => ActivitiesScreenModelState(
        userId: id,
        activities: [],
        pageState: PageState.inited,
      );
}

class ActivitiesScreenViewModel extends StateNotifier<ActivitiesScreenModelState> {
  ActivitiesScreenViewModel(ActivitiesScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getActivities(null);
  }

  void onDeleteActivity(UserActivity activity) {
    state.activities.remove(activity);
    updateState(state.copyWith(activities: [...state.activities]));
  }

  void getActivities(Function(PageState)? callback, {bool isRefresh = true}) {
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
    network.requestAsync<UserActivityResponse>(network.getUserActivities(state.userId, date: state.lastTimestamp), (newData) {
      if (newData.activities.isEmpty) {
        //no data
        if (isRefresh) {
          updateState(state.copyWith(user: newData.user, pageState: isRefresh ? PageState.empty : PageState.noMore, activities: []));
        } else {
          updateState(state.copyWith(user: newData.user, pageState: isRefresh ? PageState.empty : PageState.noMore));
        }
        // debugPrint("${state.pageState}");
      } else {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(
              user: newData.user, pageState: PageState.dataLoaded, activities: newData.activities, lastTimestamp: newData.activities.last.createdAt));
        } else {
          updateState(state.copyWith(
              user: newData.user,
              pageState: PageState.dataLoaded,
              activities: [...state.activities, ...newData.activities],
              lastTimestamp: newData.activities.last.createdAt));
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
}
