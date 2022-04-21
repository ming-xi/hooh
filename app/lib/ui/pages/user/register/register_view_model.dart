import 'package:app/extensions/extensions.dart';
import 'package:app/utils/constants.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'register_view_model.g.dart';

@CopyWith()
class RegisterModelState {
  final String? usernameErrorText;
  final String? emailErrorText;
  final String? passwordErrorText;
  final String? confirmPasswordErrorText;
  final bool registerButtonEnabled;

  RegisterModelState({this.usernameErrorText, this.emailErrorText, this.passwordErrorText, this.confirmPasswordErrorText, this.registerButtonEnabled = false});

  factory RegisterModelState.init() => RegisterModelState();
}

class RegisterViewModel extends StateNotifier<RegisterModelState> {
  RegisterViewModel(RegisterModelState state) : super(state) {}

  void register(BuildContext context, String username, String password, String email, {Function(User)? onSuccess, Function()? onFailed}) {
    network.requestAsync<LoginResponse>(network.register(username, password, email), (data) {
      network.setUserToken(data.jwtResponse.accessToken);
      if (onSuccess != null) {
        onSuccess(data.user);
      }
    }, (error) {
      if (error.errorCode == Constants.USERNAME_ALREADY_REGISTERED) {
        updateState(state.copyWith(usernameErrorText: error.message));
        return;
      } else {
        updateState(state.copyWith(usernameErrorText: null));
      }
      if (error.errorCode == Constants.EMAIL_ALREADY_VALIDATED) {
        updateState(state.copyWith(emailErrorText: error.message));
        return;
      } else {
        updateState(state.copyWith(emailErrorText: null));
      }
      if (onFailed != null) {
        onFailed();
      }
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(error.message),
            );
          });
    });
  }

  void checkUsername(String username) {
    username = username.trim();
    if (RegExp(Constants.USERNAME_REGEX).stringMatch(username) == username) {
      updateState(state.copyWith(usernameErrorText: null));
      return;
    }
    updateState(state.copyWith(usernameErrorText: "invalid username"));
  }

  void checkEmail(String email) {
    email = email.trim();
    if (RegExp(Constants.EMAIL_REGEX).stringMatch(email) == email) {
      updateState(state.copyWith(emailErrorText: null));
      return;
    }
    updateState(state.copyWith(emailErrorText: "invalid email"));
  }

  void checkPassword(String password, String confirmPassword) {
    password = password.trim();
    confirmPassword = confirmPassword.trim();
    if (password.length < 8) {
      debugPrint("len");
      updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
      return;
    }
    if (password.length > 16) {
      debugPrint("len");
      updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
      return;
    }
    if (!password.contains(RegExp("[A-Z]"))) {
      debugPrint("[A-Z]");
      updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
      return;
    }
    if (!password.contains(RegExp("[a-z]"))) {
      debugPrint("[a-z]");
      updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
      return;
    }
    if (!password.contains(RegExp("[0-9]"))) {
      debugPrint("[0-9]");
      updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
      return;
    }
    if (!password.contains(RegExp("[!@#\$&*~,.]"))) {
      debugPrint("special char");
      updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
      return;
    }
    updateState(state.copyWith(passwordErrorText: null));
    if (password != confirmPassword) {
      updateState(state.copyWith(confirmPasswordErrorText: "The password and confirmation password are different"));
      return;
    }
    updateState(state.copyWith(confirmPasswordErrorText: null));
  }
}
