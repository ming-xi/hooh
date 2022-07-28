import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/date_util.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'badges_view_model.g.dart';

@CopyWith()
class BadgesScreenModelState {
  final String userId;
  final int createdBadgeCount;
  final int receivedBadgeCount;
  final List<UserBadge> receivedBadges;
  final List<UserCreatedBadge> createdBadges;
  final PageState statsPageState;
  final PageState pageState;
  final HoohApiErrorResponse? error;
  final int page;

  BadgesScreenModelState({
    required this.userId,
    required this.receivedBadges,
    required this.createdBadgeCount,
    required this.receivedBadgeCount,
    required this.createdBadges,
    required this.statsPageState,
    required this.pageState,
    required this.page,
    required this.error,
  });

  factory BadgesScreenModelState.init(String id) => BadgesScreenModelState(
        userId: id,
        createdBadgeCount: 0,
        receivedBadgeCount: 0,
        receivedBadges: [],
        createdBadges: [],
        statsPageState: PageState.inited,
        pageState: PageState.inited,
        page: 1,
        error: null,
      );
}

class BadgesScreenViewModel extends StateNotifier<BadgesScreenModelState> {
  BadgesScreenViewModel(BadgesScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getBadgeStats();
  }

  Future<void> getBadgeStats({bool forced = false}) async {
    if (state.statsPageState == PageState.loading) {
      return;
    } else {
      if (!forced && state.statsPageState == PageState.dataLoaded) {
        return;
      }
    }
    updateState(state.copyWith(statsPageState: PageState.loading));
    network.requestAsync<UserBadgeStatsResponse>(network.getUserBadgeStats(state.userId), (data) {
      List<UserCreatedBadge> badges = data.createdBadges;
      for (int i = badges.length - 1; i >= 0; i--) {
        UserCreatedBadge current = badges[i];
        String currentDate = DateUtil.getZonedDateString(current.createdAt, format: "yyyy/MM/dd");
        if (i > 0) {
          UserCreatedBadge next = badges[i - 1];
          String nextDate = DateUtil.getZonedDateString(next.createdAt, format: "yyyy/MM/dd");
          // var currentDate = DateUtil.getZonedDateString(current.createdAt, format: FORMAT_ONLY_DATE);
          // var nextDate = DateUtil.getZonedDateString(next.createdAt, format: FORMAT_ONLY_DATE);
          current.displayDate = "$currentDate~$nextDate";
        } else {
          current.displayDate = "$currentDate~now";
        }
      }
      updateState(state.copyWith(
        statsPageState: PageState.dataLoaded,
        createdBadges: badges,
        createdBadgeCount: data.createdBadgeCount,
        receivedBadgeCount: data.receivedBadgeCount,
      ));
      getBadges((newState) => null);
    }, (error) {
      updateState(state.copyWith(
        error: error,
        statsPageState: PageState.inited,
      ));
      // debugPrint("error");
    });
  }

  void getBadges(Function(PageState)? callback, {bool isRefresh = true}) {
    if (isRefresh) {
      updateState(state.copyWith(page: 1));
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
    network.requestAsync<List<UserBadge>>(network.getUserReceivedBadges(state.userId, page: state.page), (newData) {
      if (newData.isEmpty) {
        //no data
        if (isRefresh) {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore, receivedBadges: []));
        } else {
          updateState(state.copyWith(pageState: isRefresh ? PageState.empty : PageState.noMore));
        }
        // debugPrint("${state.pageState}");
      } else {
        //has data
        if (isRefresh) {
          updateState(state.copyWith(pageState: PageState.dataLoaded, receivedBadges: newData, page: state.page + 1));
        } else {
          updateState(state.copyWith(pageState: PageState.dataLoaded, receivedBadges: [...state.receivedBadges, ...newData], page: state.page + 1));
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
