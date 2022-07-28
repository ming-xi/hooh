import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/page_state.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'wallet_view_model.g.dart';

@CopyWith()
class WalletScreenModelState {
  final UserWalletOverviewResponse? response;
  final String userId;
  final PageState pageState;

  WalletScreenModelState({
    required this.userId,
    required this.pageState,
    this.response,
  });

  factory WalletScreenModelState.init(String userId) => WalletScreenModelState(userId: userId, pageState: PageState.inited);
}

class WalletScreenViewModel extends StateNotifier<WalletScreenModelState> {
  WalletScreenViewModel(WalletScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    getOverview(null);
  }

  void getOverview(Function(HoohApiErrorResponse? error)? callback) {
    if (state.pageState == PageState.loading) {
      return;
    }
    updateState(state.copyWith(pageState: PageState.loading));
    network.requestAsync<UserWalletOverviewResponse>(network.getUserWalletOverview(state.userId), (newData) {
      updateState(state.copyWith(response: newData, pageState: PageState.dataLoaded));
      if (callback != null) {
        callback(null);
      }
    }, (error) {
      updateState(state.copyWith(
        pageState: PageState.inited,
      ));
      if (callback != null) {
        callback(error);
      }
    });
  }
}
