import 'package:app/extensions/extensions.dart';
import 'package:app/utils/constants.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'login_view_model.g.dart';

@CopyWith()
class LoginModelState {
  final bool loginButtonEnabled;
  final bool passwordVisible;

  LoginModelState({this.loginButtonEnabled = false, this.passwordVisible = false});

  factory LoginModelState.init() => LoginModelState();
}

class LoginViewModel extends StateNotifier<LoginModelState> {
  LoginViewModel(LoginModelState state) : super(state) {}

  void togglePasswordVisible() {
    updateState(state.copyWith(passwordVisible: !state.passwordVisible));
  }

  void login(BuildContext context, String username, String password, {Function(User)? onSuccess, Function()? onFailed}) {
    network.requestAsync<LoginResponse>(network.login(username, password), (data) {
      network.setUserToken(data.jwtResponse.accessToken);
      if (onSuccess != null) {
        onSuccess(data.user);
      }
    }, (error) {
      if (onFailed != null) {
        onFailed();
      }
      String msg = error.message;
      if (error.errorCode == Constants.INVALID_USERNAME_AND_PASSWORD) {
        msg = "用户名或密码错误";
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