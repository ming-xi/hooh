import 'package:app/global.dart';
import 'package:app/utils/constants.dart';
import 'package:common/extensions/extensions.dart';
import 'package:common/models/hooh_api_error_response.dart';
import 'package:common/models/network/responses.dart';
import 'package:common/utils/network.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'check_password_view_model.g.dart';

@CopyWith()
class CheckPasswordScreenModelState {
  final String? errorText;
  final String username;
  final bool buttonEnabled;

  CheckPasswordScreenModelState({
    this.errorText,
    required this.username,
    required this.buttonEnabled,
  });

  factory CheckPasswordScreenModelState.init(String username) => CheckPasswordScreenModelState(username: username, buttonEnabled: false);
}

class CheckPasswordScreenViewModel extends StateNotifier<CheckPasswordScreenModelState> {
  CheckPasswordScreenViewModel(CheckPasswordScreenModelState state) : super(state) {}

  void checkPassword(BuildContext context, String password, {required void Function() onSuccess, required void Function(HoohApiErrorResponse error) onFailed}) {
    network.requestAsync<LoginResponse>(network.login(state.username, password), (_) {
      onSuccess();
    }, (error) {
      if (error.errorCode == Constants.INVALID_USERNAME_AND_PASSWORD) {
        updateState(state.copyWith(errorText: globalLocalizations.login_wrong_password));
      }
      onFailed(error);
    });
  }

  void updateButtonState(bool enabled) {
    updateState(state.copyWith(buttonEnabled: enabled));
  }
}
