import 'package:app/global.dart';
import 'package:app/utils/constants.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'reset_password_view_model.g.dart';

@CopyWith()
class ResetPasswordScreenModelState {
  final String? passwordErrorText;
  final String? confirmPasswordErrorText;
  final bool buttonEnabled;
  final String token;

  ResetPasswordScreenModelState({
    this.passwordErrorText,
    this.confirmPasswordErrorText,
    required this.buttonEnabled,
    required this.token,
  });

  factory ResetPasswordScreenModelState.init(String token) => ResetPasswordScreenModelState(buttonEnabled: false, token: token);
}

class ResetPasswordScreenViewModel extends StateNotifier<ResetPasswordScreenModelState> {
  ResetPasswordScreenViewModel(ResetPasswordScreenModelState state) : super(state) {}

  void resetPassword(BuildContext context, String password,
      {required void Function(User) onSuccess, required void Function(HoohApiErrorResponse error) onFailed}) {
    network.requestAsync<User>(network.resetPassword(state.token, password), (user) {
      onSuccess(user);
    }, (error) {
      onFailed(error);
    });
  }

  void checkAll(String password, String confirmPassword) {
    bool isPasswordOk = _checkPassword(password, confirmPassword);
    if (isPasswordOk) {
      updateState(state.copyWith(buttonEnabled: true));
    } else {
      updateState(state.copyWith(buttonEnabled: false));
    }
  }

  bool _checkPassword(String password, String confirmPassword) {
    password = password.trim();
    confirmPassword = confirmPassword.trim();
    if (password.isEmpty && confirmPassword.isEmpty) {
      //不修改错误提示
      return false;
    }
    bool result = true;
    var stringMatch = RegExp(Constants.PASSWORD_REGEX).stringMatch(password);
    if (stringMatch != password) {
      updateState(state.copyWith(passwordErrorText: globalLocalizations.register_password_hint));
      result = result && false;
    } else {
      updateState(state.copyWith(passwordErrorText: null));
    }
    if (password != confirmPassword) {
      updateState(state.copyWith(confirmPasswordErrorText: globalLocalizations.register_password_different));
      result = result && false;
    } else {
      updateState(state.copyWith(confirmPasswordErrorText: null));
    }
    return result;
  }

  void updateButtonState(bool enabled) {
    updateState(state.copyWith(buttonEnabled: enabled));
  }
}
