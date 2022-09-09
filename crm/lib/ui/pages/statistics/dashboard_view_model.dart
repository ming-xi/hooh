import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/requests.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/models/template.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'dashboard_view_model.g.dart';

@CopyWith()
class DashboardPageModelState {
  final int? total;
  final int? totalReal;
  final int? yesterdayLoginUsers;
  final PageState pageState;

  DashboardPageModelState({this.total, this.totalReal, this.yesterdayLoginUsers, this.pageState = PageState.inited});

  factory DashboardPageModelState.init() {
    return DashboardPageModelState();
  }
}

class DashboardPageViewModel extends StateNotifier<DashboardPageModelState> {
  DashboardPageViewModel(DashboardPageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getUserStatistics();
  }

  void getUserStatistics({void Function(PageState state)? onSuccess, Function(HoohApiErrorResponse error)? onFailed}) {
    updateState(state.copyWith(pageState: PageState.loading));

    network.requestAsync<UserStatisticsResponse>(
      network.crmGetStatisticsOfUsers(),
      (newData) {
        updateState(state.copyWith(
            total: newData.total, totalReal: newData.totalReal, yesterdayLoginUsers: newData.yesterdayLoginUsers, pageState: PageState.dataLoaded));
        if (onSuccess != null) {
          onSuccess(state.pageState);
        }
      },
      (error) {
        updateState(state.copyWith(pageState: PageState.inited));
        if (onFailed != null) {
          onFailed(error);
        }
      },
    );
  }
}
