import 'package:common/extensions/extensions.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:crm/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'home_view_model.g.dart';

@CopyWith()
class HomeScreenModelState {
  final int? selectedPageId;

  HomeScreenModelState({this.selectedPageId});

  factory HomeScreenModelState.init(int defaultPageId) {
    return HomeScreenModelState(selectedPageId: defaultPageId);
  }
}

class HomeScreenViewModel extends StateNotifier<HomeScreenModelState> {
  HomeScreenViewModel(HomeScreenModelState state) : super(state) {
    // 如果需要加载时自动拉取数据，在这里调用
    // search(isRefresh: true);
  }

  void login(BuildContext context, String username, String password, {void Function(LoginResponse)? onSuccess, Function()? onFailed}) {
    network.requestAsync<LoginResponse>(network.crmLogin(username, password), (data) {
      if (onSuccess != null) {
        onSuccess(data);
      }
    }, (error) {
      if (onFailed != null) {
        onFailed();
      }
      String msg = error.message;
      if (error.errorCode == Constants.INVALID_USERNAME_AND_PASSWORD) {
        msg = "密码错误";
      } else if (error.errorCode == Constants.USER_IS_NOT_ADMIN) {
        msg = "你不是管理员";
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(msg),
            );
          });
    });
  }

  void changePage(int pageId) {
    updateState(state.copyWith(selectedPageId: pageId));
  }
}
