import 'package:common/extensions/extensions.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'me_model.g.dart';

@CopyWith()
class MePageModelState {
  final String userId;
  final User? user;
  final UserWalletResponse? wallet;
  final UnreadNotificationCountResponse? unread;

  MePageModelState({
    required this.userId,
    this.user,
    this.wallet,
    this.unread,
  });

  factory MePageModelState.init(String id, {User? user}) => MePageModelState(userId: id, user: user);
}

class MePageViewModel extends StateNotifier<MePageModelState> {
  MePageViewModel(MePageModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    refresh();
  }

  Future<void> refresh({Function()? callback}) async {
    User user = await getUserInfo();
    UserWalletResponse wallet = await getWalletInfo();
    UnreadNotificationCountResponse unread = await getUnreadNotificationCount();

    updateState(state.copyWith(
      user: user,
      wallet: wallet,
      unread: unread,
    ));
    if (callback != null) {
      callback();
    }
  }

  Future<User> getUserInfo() async {
    return await network.getUserInfo(state.userId);
  }

  Future<UserWalletResponse> getWalletInfo() async {
    return await network.getUserWalletInfo(state.userId);
  }

  Future<UnreadNotificationCountResponse> getUnreadNotificationCount() async {
    return await network.getUnreadNotificationCount();
  }
}
