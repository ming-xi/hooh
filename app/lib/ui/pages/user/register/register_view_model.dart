import 'package:app/extensions/extensions.dart';
import 'package:app/ui/widgets/toast.dart';
import 'package:app/utils/constants.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/models/user.dart';
import 'package:common/utils/network.dart';
import 'package:common/utils/preferences.dart';
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

  RegisterModelState({
    this.usernameErrorText,
    this.emailErrorText,
    this.passwordErrorText,
    this.confirmPasswordErrorText,
  });

  factory RegisterModelState.init() => RegisterModelState();
}

class RegisterViewModel extends StateNotifier<RegisterModelState> {
  RegisterViewModel(RegisterModelState state) : super(state) {}

  void register(BuildContext context, String username, String password, String email, {Function(User)? onSuccess, Function()? onFailed}) {
    network.requestAsync<LoginResponse>(network.register(username, password, email), (data) {
      Toast.showSnackBar(context, "success");
      network.setUserToken(data.jwtResponse.accessToken);
      preferences.putInt(Preferences.keyUserRegisterStep, data.user.register_step);
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
    // if (password.length < 8) {
    //   updateState(state.copyWith(confirmPasswordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // if (password.length > 16) {
    //   updateState(state.copyWith(confirmPasswordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // if (!password.contains(RegExp("[A-Z]]"))) {
    //   updateState(state.copyWith(confirmPasswordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // if (!password.contains(RegExp("[a-z]]"))) {
    //   updateState(state.copyWith(confirmPasswordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // if (!password.contains(RegExp("[0-9]]"))) {
    //   updateState(state.copyWith(confirmPasswordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // if (!password.contains(RegExp("[0-9]]"))) {
    //   updateState(state.copyWith(confirmPasswordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // var zmReg   = "[A-Z]";
    // var zm2Reg   = "[a-z]";
    // var numReg  = "[0-9]";
    // var zfReg   = "[^A-Za-z0-9s]";
    // var empty   = "s/g";
    // var chinese = "[\u4e00-\u9fa5]/g";
    // var complex = 0;
    // if (RegExp(chinese).hasMatch(password)) {
    //   debugPrint("1");
    //   updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // if (RegExp(empty).hasMatch(password)) {
    //   debugPrint("2");
    //   updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // if (RegExp(zmReg).hasMatch(password)) {
    //   debugPrint("3");
    // ++complex;
    // }
    // if (RegExp(zm2Reg).hasMatch(password)) {
    //   debugPrint("4");
    // ++complex;
    // }
    // if (RegExp(numReg).hasMatch(password)) {
    //   debugPrint("5");
    // ++complex;
    // }
    // if (RegExp(zfReg).hasMatch(password)) {
    //   debugPrint("6");
    // ++complex;
    // }
    // if (complex < 4 || password.length < 8 || password.length > 16) {
    // // 密码需包含字母，符号或者数字中至少两项且长度超过6位数，最多不超过16位数
    //   debugPrint("7");
    //   updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    // var stringMatch = RegExp(Constants.PASSWORD_REGEX).stringMatch(password);
    // debugPrint(stringMatch);
    // if (stringMatch != password) {
    //   updateState(state.copyWith(passwordErrorText: "Must contain numbers,letters.symbol\nMust contain 8-16 characters"));
    //   return;
    // }
    if (password != confirmPassword) {
      updateState(state.copyWith(confirmPasswordErrorText: "The password and confirmation password are different"));
      return;
    }
    updateState(state.copyWith(passwordErrorText: null));
    updateState(state.copyWith(confirmPasswordErrorText: null));
  }
}
