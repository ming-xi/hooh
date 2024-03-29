import 'package:app/global.dart';
import 'package:common/extensions/extensions.dart';
import 'package:app/utils/constants.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/ui_utils.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'login_view_model.g.dart';

@CopyWith()
class LoginScreenModelState {
  final bool loginButtonEnabled;
  final bool passwordVisible;

  LoginScreenModelState({this.loginButtonEnabled = false, this.passwordVisible = false});

  factory LoginScreenModelState.init() => LoginScreenModelState();
}

class LoginScreenViewModel extends StateNotifier<LoginScreenModelState> {
  LoginScreenViewModel(LoginScreenModelState state) : super(state) {}

  void togglePasswordVisible() {
    updateState(state.copyWith(passwordVisible: !state.passwordVisible));
  }

  void login(BuildContext context, String username, String password, {void Function(LoginResponse)? onSuccess, Function()? onFailed}) {
    network.requestAsync<LoginResponse>(network.login(username, password), (data) {
      if (onSuccess != null) {
        onSuccess(data);
      }
    }, (error) {
      if (onFailed != null) {
        onFailed();
      }
      String msg = error.message;
      if (error.errorCode == Constants.INVALID_USERNAME_AND_PASSWORD) {
        msg = globalLocalizations.login_wrong_password;
      }
      showHoohDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(msg),
            );
          });
    });
  }

  void checkUsernameAndPassword(String username, String password) {
    username = username.trim();
    password = password.trim();
    if (username.isEmpty) {
      updateState(state.copyWith(loginButtonEnabled: false));
      return;
    }
    if (password.isEmpty) {
      updateState(state.copyWith(loginButtonEnabled: false));
      return;
    }
    updateState(state.copyWith(loginButtonEnabled: true));
  }
}
