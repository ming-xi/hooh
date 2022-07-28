import 'package:common/extensions/extensions.dart';
import 'package:app/global.dart';
import 'package:app/ui/widgets/appbar.dart';
import 'package:app/utils/constants.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'register_view_model.g.dart';

@CopyWith()
class RegisterScreenModelState {
  final String? usernameErrorText;
  final String? emailErrorText;
  final String? passwordErrorText;
  final String? confirmPasswordErrorText;
  final bool registerButtonEnabled;
  final bool passwordVisible;
  final bool confirmPasswordVisible;

  RegisterScreenModelState(
      {this.usernameErrorText,
      this.emailErrorText,
      this.passwordErrorText,
      this.confirmPasswordErrorText,
      this.registerButtonEnabled = false,
      this.passwordVisible = false,
      this.confirmPasswordVisible = false});

  factory RegisterScreenModelState.init() => RegisterScreenModelState();
}

class RegisterScreenViewModel extends StateNotifier<RegisterScreenModelState> {
  RegisterScreenViewModel(RegisterScreenModelState state) : super(state) {}

  void togglePasswordVisible() {
    updateState(state.copyWith(passwordVisible: !state.passwordVisible));
  }

  void toggleConfirmPasswordVisible() {
    updateState(state.copyWith(confirmPasswordVisible: !state.confirmPasswordVisible));
  }

  void register(BuildContext context, String username, String password, String email,
      {void Function(LoginResponse)? onSuccess, Function(HoohApiErrorResponse)? onFailed}) {
    network.requestAsync<LoginResponse>(network.register(username, password, email), (data) {
      // network.setUserToken(data.jwtResponse.accessToken);
      if (onSuccess != null) {
        onSuccess(data);
      }
    }, (error) {
      if (error.errorCode == Constants.USERNAME_ALREADY_REGISTERED) {
        updateState(state.copyWith(usernameErrorText: error.message));
        if (onFailed != null) {
          onFailed(error);
        }
        return;
      } else {
        updateState(state.copyWith(usernameErrorText: null));
      }
      if (error.errorCode == Constants.EMAIL_ALREADY_VALIDATED) {
        updateState(state.copyWith(emailErrorText: error.message));
        if (onFailed != null) {
          onFailed(error);
        }
        return;
      } else {
        updateState(state.copyWith(emailErrorText: null));
        if (onFailed != null) {
          onFailed(error);
        }
      }
      // showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         content: Text(error.message),
      //       );
      //     });
    });
  }

  void checkAll(String username, String email, String password, String confirmPassword) {
    bool isUsernameOk = _checkUsername(username);
    bool isEmailOk = _checkEmail(email);
    bool isPasswordOk = _checkPassword(password, confirmPassword);
    if (isUsernameOk && isEmailOk && isPasswordOk) {
      updateState(state.copyWith(registerButtonEnabled: true));
    } else {
      updateState(state.copyWith(registerButtonEnabled: false));
    }
  }

  bool _checkUsername(String username) {
    username = username.trim();
    if (username.isEmpty) {
      //不修改错误提示
      return false;
    }
    if (RegExp(Constants.USERNAME_REGEX).stringMatch(username) == username) {
      updateState(state.copyWith(usernameErrorText: null));
      return true;
    }
    updateState(state.copyWith(usernameErrorText: "invalid username"));
    return false;
  }

  bool _checkEmail(String email) {
    email = email.trim();
    if (email.isEmpty) {
      //不修改错误提示
      return false;
    }
    if (RegExp(Constants.EMAIL_REGEX).stringMatch(email) == email) {
      updateState(state.copyWith(emailErrorText: null));
      return true;
    }
    updateState(state.copyWith(emailErrorText: "invalid email"));
    return false;
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
}
