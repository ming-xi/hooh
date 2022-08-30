import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'notifications_view_model.g.dart';

@CopyWith()
class SystemNotificationScreenModelState {
  final List<SystemNotification> notifications;
  final PageState pageState;
  final HoohApiErrorResponse? error;
  final DateTime? lastTimestamp;

  SystemNotificationScreenModelState({
    required this.notifications,
    required this.pageState,
    this.error,
    this.lastTimestamp,
  });

  factory SystemNotificationScreenModelState.init() => SystemNotificationScreenModelState(
        notifications: [],
        pageState: PageState.inited,
      );
}

class SystemNotificationScreenViewModel extends StateNotifier<SystemNotificationScreenModelState> {
  SystemNotificationScreenViewModel(SystemNotificationScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getNotifications(null);
  }

  void getNotifications(Function(PageState)? callback, {bool isRefresh = true}) {
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
    network.requestAsync<List<SystemNotification>>(network.getSystemNotifications(date: state.lastTimestamp), (newData) {
      if (isRefresh) {
        _updateLastRefreshData();
      }
      if (newData.isEmpty) {
        //no data
        if (isRefresh) {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore, notifications: []));
        } else {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore));
        }
        // debugPrint("${state.pageState}");
      } else {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(pageState: PageState.dataLoaded, notifications: newData, lastTimestamp: newData.last.createdAt));
        } else {
          updateState(
              state.copyWith(pageState: PageState.dataLoaded, notifications: [...state.notifications, ...newData], lastTimestamp: newData.last.createdAt));
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

  void _updateLastRefreshData() {
    // preferences.putInt(Preferences.KEY_LAST_SYSTEM_NOTIFICATIONS_READ, DateUtil.getCurrentUtcDate().millisecondsSinceEpoch);
    preferences.putString(Preferences.KEY_LAST_SYSTEM_NOTIFICATIONS_READ_STRING, DateUtil.getUtcDateString(DateUtil.getCurrentUtcDate()));
  }
}
